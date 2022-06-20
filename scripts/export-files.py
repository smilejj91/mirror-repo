from os import path, makedirs, getenv, chdir, walk, listdir, unlink
import subprocess
import re
import argparse
import json
import apt_pkg
import shutil

arg_parser = argparse.ArgumentParser(description="get distribution and package name")
arg_parser.add_argument("distribution", nargs=1)
arg_parser.add_argument("package_name", nargs=1)

args = arg_parser.parse_args()
dist_name = args.distribution[0]
pkg_name = args.package_name[0]

tmp_path = getenv('HOME') + "/.source_package/"
component = "main"
source_path = tmp_path + dist_name + "/Sources"
package_list_json_path = tmp_path + dist_name + "/package_list.json"

sources_list_path = "/etc/apt/sources.list.d/tmp-list-for-exporting-files.list"
url = "http://b2b-repo.tmaxos.net/tmax"

class PackageListParser():
    def __init__(self, dist_name):
        self.sources = []
        self.package_list = {}
        self.dist = dist_name

    def run(self):
        self.init_dir()
        self.download_sources()
        self.package_list = self.parse_sources()

    def init_dir(self):
        makedirs(tmp_path + self.dist, exist_ok=True)
    
    def download_sources(self):
        sources_url = url + "/dists/" + self.dist + "/" + component
        source_suffix = "/source/Sources"
        subprocess.run(["wget", "-q", sources_url + source_suffix, "-O", source_path])

    def parse_sources(self):
        with open(source_path) as f:
            self.sources = f.readlines()
        sources = self.sources
        package_list = {}
        package_name = ""
        version = ""
        mail = ""
        for line in sources:
            if "Package: " in line:
                package_name = line[9:-1]
            if "Version: " in line and "Standard" not in line:
                version = line[9:-1]
            if "Maintainer: " in line:
                mail = line[line.find("<")+1:line.find(">")]
            if line == "\n": # end of package description
                # if "tos" in version or "tmax" in version:
                package_list[package_name] = {"version": version, "mail": mail}        
        
        return package_list


class ExportFiles():
    def __init__(self, package_list, dist_name):
        self.package_list = package_list
        self.copyright = ""
        self.changelog = ""
        self.local_list = {}
        self.dist = dist_name
        self.cnt = 0
    
    def init_tree(self):
        apt_pkg.init()
        self.load_package_list_json()
        self.apt_setup()
        self.update_tree()

    def load_package_list_json(self):
        if path.exists(package_list_json_path):
            with open(package_list_json_path, 'r') as f_out:
                self.local_list = json.load(f_out)
    
    def apt_setup(self):
        suffix = url + " " + dist_name + " " + component + "\n"
        source_line = "deb-src " + suffix
        binary_line = "deb " + suffix
        with open(sources_list_path, "wt") as f:
            f.write(source_line)
            f.write(binary_line)
        
        subprocess.run(["apt", "-qq", "update"])

    def update_tree(self):
        chdir(tmp_path + self.dist)
        makedirs("pool/main", exist_ok=True)
        package_list = self.package_list
        
        for package_name in package_list:
            if not self.is_new(package_name):
                continue

            self.download_source_package(package_name)
            
        with open(package_list_json_path, "wt") as f_in:
            json.dump(package_list, f_in)

    def download_source_package(self, package_name):
        dir_name = self.get_dir_path(package_name)
        
        shutil.rmtree(dir_name, ignore_errors=True)
        makedirs(dir_name, exist_ok=True)
        chdir(dir_name)
        subprocess.run(["apt", "-qq", "source", package_name, "-t", self.dist])
    
    def print_changelog(self, package_name):
        dir_name = self.get_dir_path(package_name)
        package_path = ""
        for item in listdir(dir_name):
            if path.isdir(dir_name+item):
                package_path = item
        changelog_path = dir_name + package_path + "/debian/changelog"

        with open(changelog_path, "rt") as f_out:
            print(f_out.read())
        
    def get_dir_path(self, package_name):
        path_prefix = tmp_path + self.dist + "/pool/main/"
        lib_re = re.compile("^(lib)[a-zA-Z0-9\-]*")
        lib_prefix = ""
        head_letter_idx = 0
        if lib_re.match(package_name) is not None:
            lib_prefix = "lib"
            head_letter_idx = 3
        
        head_dir_name = path_prefix + lib_prefix + package_name[head_letter_idx]
        dir_name = head_dir_name + "/" + package_name + "/"

        return dir_name

    def clean_up_sourcelist(self):
        unlink(sources_list_path)

    # def parse_copyright(self, package_name, copyright_path):
    #     if not path.exists(copyright_path):
    #         print(copyright_path + " not exists")
    #         return
    #     self.cnt = self.cnt + 1
    #     copyright_string_list = []
    #     header = str(self.cnt) + ". " + package_name + "\n\n"
    #     copyright_string_list.append(header)
    #     with open(copyright_path, "r") as f_in:
    #         copyright_string_list.append(f_in.read())
        
    #     self.copyright = self.copyright + "".join(copyright_string_list)
    
    # def parse_changelog(self, package_name, version, changelog_path):
    #     if not path.exists(changelog_path):
    #         return
        
    def create_copyright_file(self):
        with open(copyright_path, "wt") as f_out:
            f_out.write(self.copyright)
            
    def is_new(self, package_name):
        if package_name not in self.local_list.keys():
            return True
        else:
            return self.is_newer_version(self.package_list[package_name]['version'], self.local_list[package_name]['version'])

    def is_newer_version(self, downloaded_version, stored_version):
        return apt_pkg.version_compare(downloaded_version, stored_version) > 0

    # def parse_changelog(self):

package_list_parser = PackageListParser(dist_name)
package_list_parser.run()

# print(len(package_list_parser.package_list))

export_files = ExportFiles(package_list_parser.package_list, dist_name)
export_files.init_tree()
export_files.print_changelog(pkg_name)
export_files.clean_up_sourcelist()

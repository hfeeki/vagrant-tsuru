
import sys, os

if __name__ == '__main__':
    if len(sys.argv) == 2:
	subm = sys.argv[1]
        print("remove section in .git/config : ")
        os.system("git config -f .git/config --remove-section submodule.%s" % subm)
        print("remove section in .gitmodules : ")
        os.system("git config -f .gitmodules --remove-section submodule.%s" % subm)
        print("remove cached submodule path: ")
        os.system("git rm --cached %s" % subm)
        print("remove submodule path: ")
        os.system("rm -rf %s" % subm)
        print("remove .git/modules/%s" % subm)
        os.system("rm -rf .git/modules/%s" % subm)
    else:
        print("Usage: git-rm-submodule <submodule-path>")

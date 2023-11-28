import argparse
import json
import os
import re
import subprocess

TOPDIR=os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
VSCODE_DIR=os.path.join(TOPDIR, ".vscode")
SETTINGS=os.path.join(VSCODE_DIR, "settings.json")
CMAKE_KITS=os.path.join(VSCODE_DIR, "cmake-kits.json")

def removeRedundantComma(text):
    """
    移除json多余逗号，避免json.loads报错
    """
    rex = r"""(?<=[}\]"'])\s*,\s*(?!\s*[{["'])"""
    return re.sub(rex, "", text, 0)

def readVscodeJsonFile(file, default = {}):
    if not os.path.exists(VSCODE_DIR):
        return default
    if not os.path.exists(file):
        return default
    with open(file) as f:
        return json.loads(removeRedundantComma(f.read()))
    
def writeVscodeJsonFile(values, file):
    if not os.path.exists(VSCODE_DIR):
        os.mkdir(VSCODE_DIR)
    with open(file, 'w') as f:
        json.dump(values, f, indent=4)

def readSettings():
    return readVscodeJsonFile(SETTINGS)

def writeSettings(settings):
    writeVscodeJsonFile(settings, SETTINGS)


def readCmakeKits():
    return readVscodeJsonFile(CMAKE_KITS, default=[])


def writeCmakeKits(cmakeKits):
    writeVscodeJsonFile(cmakeKits, CMAKE_KITS)


def setDefault(settings, defaultDict):
    for key in defaultDict:
        if key not in settings:
            settings[key] = defaultDict[key]

def setupGitCommitPlugin(settings):
    defaultDict = {
        "GitCommitPlugin.ShowEmoji": False,
        "GitCommitPlugin.MaxSubjectCharacters": 40
    }
    setDefault(settings, defaultDict)


buildrootVarsCache = {}
def getBuildrootVar(key):
    if key in buildrootVarsCache:
        return buildrootVarsCache[key]
    
    cmd = ["smake", "-s", "printvars", "VARS=" + key]
    with open(os.devnull, 'wb') as devnull:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=devnull,
                             universal_newlines=True)
        value = re.search(r'^{key}=(.*)$'.format(key=key), p.communicate()[0], re.MULTILINE).group(1)
        buildrootVarsCache[key] = value
        return value


def setupCommon(args):
    settings = readSettings()
    setupGitCommitPlugin(settings)
    writeSettings(settings)

def setupCmake(args):
    settings = readSettings()
    outDir = getBuildrootVar('O')
    defaultDict = {
        "cmake.buildDirectory": "${sourceDirectory}/CMakeBuilds",
        "cmake.cmakePath": outDir + "/host/bin/cmake",
        "cmake.sourceDirectory": []
    }

    if args.project:
        projeceSrcDir = getBuildrootVar(args.project.upper() + "_SITE")
        defaultDict["cmake.sourceDirectory"].append(projeceSrcDir)

    setDefault(settings, defaultDict)
    writeSettings(settings)

    cmakeKits = readCmakeKits()
    found = False
    for cmakeKit in cmakeKits:
        if cmakeKit["name"] == "Buildroot toolchain":
            found = True
    
    if not found:
        cmakeKits.append({
            "name": "Buildroot toolchain",
            "toolchainFile": outDir + "/host/share/buildroot/toolchainfile.cmake"
        })
        writeCmakeKits(cmakeKits)
    

def main():
    parser = argparse.ArgumentParser(description='配置vscode环境')
    parser.add_argument('-f', '--file', help="指定.smake.local文件")
    subparsers = parser.add_subparsers(title="选择配置模块")
    common_parser = subparsers.add_parser("common", help="通用配置")
    common_parser.set_defaults(func=setupCommon)

    set_parser = subparsers.add_parser("cmake", help="cmake配置")
    set_parser.add_argument('project', type=str)
    set_parser.set_defaults(func=setupCmake)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()

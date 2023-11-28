import argparse
import json
import os

def get(args):
    if not os.path.exists(args.file):
        return
    with open(args.file, 'r') as f:
        conf = json.load(f)
        print(conf[args.key])

def set(args):
    conf = {}
    if os.path.exists(args.file):
        with open(args.file, 'r') as f:
            conf = json.load(f)
    
    if args.key and args.value:
        conf[args.key] = args.value
    if args.pairs :
        for pair in args.pairs:
            res = pair.split("=")
            conf[res[0]] = res[1]
    
    with open(args.file, 'w') as f:
        json.dump(conf, f, indent=4)

def main():
    parser = argparse.ArgumentParser(description='读取和写入.smake.local文件')
    parser.add_argument('-f', '--file', help="指定.smake.local文件")
    subparsers = parser.add_subparsers(title="get or set")
    get_parser = subparsers.add_parser("get", help="获取值")
    get_parser.add_argument('-k', '--key', type=str, required=True)
    get_parser.set_defaults(func=get)

    set_parser = subparsers.add_parser("set", help="设置值")
    set_parser.add_argument('-k', '--key', type=str)
    set_parser.add_argument('-v', '--value', type=str)
    set_parser.add_argument('--pairs', nargs='+', help="键值对列表")
    set_parser.set_defaults(func=set)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()

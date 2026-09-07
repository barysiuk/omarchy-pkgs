#!/usr/bin/env python3
"""Verify Surface Pro 12 UKI DTB sections, including PE raw padding."""
import argparse, hashlib, struct, sys
from pathlib import Path
COMPATIBLE=b"microsoft,surface-pro-12in\0"
SHA256="d7ed4b073c7344cb0bb2c3f7d00655df60b473588a5c0364af54537dc2c672c7"
REQUIRED=("initramfs_async=0","clk_ignore_unused","pd_ignore_unused","arm64.nopauth")
FORBIDDEN=("archiso", "systemd.tpm2_wait=0", "modprobe.blacklist=qcom_q6v5_pas", "debug")
def sections(image):
 pe=struct.unpack_from('<I',image,0x3c)[0]
 if image[pe:pe+4]!=b'PE\0\0': raise ValueError('not a PE image')
 count=struct.unpack_from('<H',image,pe+6)[0]; optional=struct.unpack_from('<H',image,pe+20)[0]; table=pe+24+optional
 out=[]
 for off in range(table,table+count*40,40):
  name=image[off:off+8].rstrip(b'\0'); size=struct.unpack_from('<I',image,off+16)[0]; ptr=struct.unpack_from('<I',image,off+20)[0]
  out.append((name,image[ptr:ptr+size]))
 return out
def dtb(payload):
 if payload[:4]!=b'\xd0\r\xfe\xed': raise ValueError('invalid FDT magic')
 size=struct.unpack_from('>I',payload,4)[0]
 if size>len(payload): raise ValueError('FDT total size exceeds PE section')
 return payload[:size]
def verify(path, installed=False):
 by={}
 for n,p in sections(Path(path).read_bytes()): by.setdefault(n,[]).append(p)
 trees=by.get(b'.dtb',[])
 if len(trees)!=1: raise ValueError('UKI lacks exactly one fixed .dtb section')
 tree=dtb(trees[0])
 if COMPATIBLE not in tree or hashlib.sha256(tree).hexdigest()!=SHA256: raise ValueError('fixed DTB incompatible or has unexpected hash')
 if installed:
  if b'.dtbauto' in by or b'.hwids' in by: raise ValueError('installed UKI must not use DTB auto/HWID selection')
  cmdlines=by.get(b'.cmdline',[])
  if len(cmdlines)!=1: raise ValueError('installed UKI lacks exactly one .cmdline section')
  cmd=cmdlines[0].split(b'\0',1)[0].decode(errors='replace').split()
  missing=[x for x in REQUIRED if x not in cmd]; forbidden=[x for x in FORBIDDEN if x in cmd]
  if missing or forbidden: raise ValueError(f'cmdline missing={missing} forbidden={forbidden}')
def main():
 p=argparse.ArgumentParser();p.add_argument('uki',type=Path);p.add_argument('--installed',action='store_true');a=p.parse_args()
 try: verify(a.uki,a.installed)
 except (OSError,ValueError,struct.error,IndexError) as e: sys.exit(f'verify-surface-uki: {e}')
if __name__=='__main__': main()

#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ugly script to copy purpleplatform encrypted videos when they are being run by
# their player and are decrypted. The DRM key (64 bits truncated to 32, XOR
# between encrypted and decrypted file) changes for each file, apart of a few
# bits. Was quicker to get the decrypted file this way
# run script before using the player, every played file will be decrypted and
# copied to .media/decrypted


import numpy as np
import os, time
import pickle
from shutil import copyfile
import sys

def dict_mod(dicta, dictb):
    return [key for key in dicta.keys() if any(dicta[key] != dictb[key])]

def save_obj(obj, name ):
    with open(name + '.pkl', 'wb') as f:
        pickle.dump(obj, f, pickle.HIGHEST_PROTOCOL)

def load_obj(name ):
    with open(name + '.pkl', 'rb') as f:
        return pickle.load(f)

def ls_mov(mov_path):
    files_to_decrypt = []
    for file in os.listdir("."):
        if file.endswith(".mov"):
            files_to_decrypt.append(file)
    return files_to_decrypt

def get_crypted_bytes_file(mov_crypted_filepath):
    crypt = np.fromfile(mov_crypted_filepath, dtype=np.byte)

    # the key is one time pad. 64 truncated to 32 bytes, repeated every 1024
    # bytes
    first_32_bytes = crypt[0:32]
    return first_32_bytes

def db_bytes_encrypted(mov_path):
    files_to_decrypt = ls_mov(mov_path)
    dict = {}
    for file in files_to_decrypt:
        dict[file] = get_crypted_bytes_file(file)

    if not os.path.exists(os.path.join(mov_path, 'db_bytes')):
        save_obj(dict, os.path.join(mov_path, 'db_bytes'))

    return dict

def copy_decrypted_file(mov_path):
    dcr_path = os.path.join(mov_path, 'decrypted')
    if not os.path.exists(dcr_path):
        os.mkdir(os.path.join(dcr_path))
    files_to_decrypt = ls_mov(mov_path)
    files_decrytped  = ls_mov(dcr_path)

    dict_encrypted_bytes = db_bytes_encrypted(mov_path)

    if len(files_decrytped) < files_to_decrypt :
        while 1:
            dict_whileplayerrunning_bytes = db_bytes_encrypted(mov_path)
            diff = dict_mod(dict_encrypted_bytes, dict_whileplayerrunning_bytes)
            if diff != []:
                for f in diff:
                    if not os.path.exists(os.path.join(dcr_path, os.path.basename(f))):
                        print 'copy %s decrypted' % os.path.basename(f)
                        copyfile(f, os.path.join(dcr_path, os.path.basename(f)))

            if len(files_decrytped) == files_to_decrypt:
                exit(0)
            time.sleep(1)

if __name__ == "__main__":
    copy_decrypted_file('.')

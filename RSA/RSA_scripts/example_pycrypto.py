#! /usr/bin/env python3

from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA #sudo pip3 install -U PyCryptodome


def main():
    key = RSA.generate(2048)
    rsa = PKCS1_OAEP.new(key)
    c = rsa.encrypt(b'hello, world!')
    m = rsa.decrypt(c)
    print("M: ", m.decode())
    print("N: ", key.n)
    print("p: ", key.p)
    print("q: ", key.q)
    print("e: ", key.e)
    print("d: ", key.d)


if __name__ == '__main__':
    main()

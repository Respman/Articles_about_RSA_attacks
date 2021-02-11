#! /usr/bin/env bash

echo '>generate 1024 bit key:'
openssl genrsa -out key 1024
echo '>key component:'
openssl pkey -in key -text

data='1337'
for ((i=1;i<32;i++))
do
    data+='1337'
done

echo '>encrypt data'
echo -ne $data | openssl rsautl -encrypt -inkey key -raw -out enc01
echo '>print encrypted data:'
hexdump -C enc01
echo '>decrypt data'
cat enc01 | openssl rsautl -decrypt -inkey key -raw -out dec01
echo '>print decrypted data:'
hexdump -C dec01

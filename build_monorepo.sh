#!/bin/bash

export PATH="$PATH:C:\Users\natya\AppData\Local\Pub\Cache\bin"

melos clean
melos bootstrap
melos exec --no-parallel -- flutter pub get


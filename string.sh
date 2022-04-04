#!/bin/bash

function append_to_string() {
    str=""
    str+="Hello"
    str+=" world"
    echo ${str}
}

function quotes_test() {
    # single quotes inside double quotes
    str="hello '${PATH}'"  # NOTE!!! 这里的变量是可以展开的,在双引号内
    echo $str  # hello 'world'

    str1='hello "${str}"'
    echo $str1  # hello "${str}" 单引号内所有内容保持原文

    ext="RAF"
    str2=" --exclude '*.${ext}'"  # 双引号内单引号不需要转义
    echo ${str2}

    name="gaga"
    echo "My name is \"${name}\"."  # 双引号内双引号需要转义
}

# append_to_string
quotes_test

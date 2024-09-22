#!/bin/bash

# 使用osascript调用AppleScript，利用Vision框架进行OCR

# 图片路径
image_path="$1"

function OCR() {
# AppleScript代码
osascript <<EOF
use framework "Foundation"
use framework "Vision"
use scripting additions
on getText(theFile)
	# set theFile to current application's |NSURL|'s fileURLWithPath:theFile
		set theFile to current application's |NSURL|'s fileURLWithPath:theFile
	set requestHandler to current application's VNImageRequestHandler's alloc()'s initWithURL:theFile options:(missing value)
	set theRequest to current application's VNRecognizeTextRequest's alloc()'s init()
	requestHandler's performRequests:(current application's NSArray's arrayWithObject:(theRequest)) |error|:(missing value)
	set theResults to theRequest's results()
	set theArray to current application's NSMutableArray's new()
	repeat with aResult in theResults
		(theArray's addObject:(((aResult's topCandidates:1)'s objectAtIndex:0)'s |string|()))
	end repeat
	return (theArray's componentsJoinedByString:linefeed) as text
end getText

set theText to getText("$1")
return theText
EOF
}

# 遍历目录中的所有文件
for file in images/*; do
  # 仅处理图片文件 (例如jpg, png, jpeg)
  if [[ $file == *.jpg ]]; then
    echo "process ${file}"
    # 获取文件名 (不含扩展名)
    filename=$(basename "$file" .jpg)

    # 调用 ocr.sh 脚本处理图片文件，并将结果存储到变量中
    result=$(OCR "$file")

    # 将结果写入到对应的txt文件
    echo "$result" > "txt/$filename.txt"
  fi
done
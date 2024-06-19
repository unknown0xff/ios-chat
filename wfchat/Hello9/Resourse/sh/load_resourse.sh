
#  read_colors.sh
#  ios-hello9
#
#  Created by Ada on 5/28/24.
#  Copyright © 2024 ios-hello9. All rights reserved.

#!/bin/sh

# 定义路径
PROJECT_DIR=$1

load_colors() {

    ASSETS_DIR="$PROJECT_DIR/Hello9/Resourse/Colors.xcassets"
    OUTPUT_FILE="$PROJECT_DIR/Hello9/Resourse/Colors.swift"

    # 检查 Colors.xcassets 目录是否存在
    if [ ! -d "$ASSETS_DIR" ]; then
      echo "Colors.xcassets directory not found!"
      exit 1
    fi

    # 检查 Colors.xcassets 目录是否存在
    if [ ! -d "$ASSETS_DIR" ]; then
      echo "Colors.xcassets directory not found!"
      exit 1
    fi

    # 清空输出文件
    echo "" > "$OUTPUT_FILE"

    echo "//  Colors.swift" >> "$OUTPUT_FILE"
    echo "//  ios-hello9" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "enum Colors {" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"


    # 遍历 Colors.xcassets 目录中的所有 .colorset 文件夹
    for dir in "$ASSETS_DIR"/*.colorset; do
      if [ -d "$dir" ]; then
        COLORS_NAME=$(basename "$dir" .colorset)
        
        # 读取每个 colorset 文件夹的 Contents.json 文件
        CONTENTS_FILE="$dir/Contents.json"
        if [ -f "$CONTENTS_FILE" ]; then
        
          # 提取颜色值
          RED=$(jq -r '.colors[0].color.components.red' "$CONTENTS_FILE")
          GREEN=$(jq -r '.colors[0].color.components.green' "$CONTENTS_FILE")
          BLUE=$(jq -r '.colors[0].color.components.blue' "$CONTENTS_FILE")

          COLOR_HEX="$RED $GREEN $BLUE"
          
          # 输出到文件
          echo "    /// $COLOR_HEX" >> "$OUTPUT_FILE"
          echo "    static let $COLORS_NAME = UIColor(named: \"$COLORS_NAME\")!" >> "$OUTPUT_FILE"
          echo "" >> "$OUTPUT_FILE"
        fi
      fi
    done

    echo "}" >> "$OUTPUT_FILE"
}

load_images() {

    ASSETS_DIR="$PROJECT_DIR/Hello9/Resourse/Images.xcassets"
    OUTPUT_FILE="$PROJECT_DIR/Hello9/Resourse/Images.swift"

    # 检查 Colors.xcassets 目录是否存在
    if [ ! -d "$ASSETS_DIR" ]; then
      echo "Images.xcassets directory not found!"
      exit 1
    fi

    # 检查 Colors.xcassets 目录是否存在
    if [ ! -d "$ASSETS_DIR" ]; then
      echo "Images.xcassets directory not found!"
      exit 1
    fi

    # 清空输出文件
    echo "" > "$OUTPUT_FILE"

    echo "//  Images.swift" >> "$OUTPUT_FILE"
    echo "//  ios-hello9" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "enum Images {" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"


    # 遍历 Images.xcassets 目录中的所有 .imageset 文件夹
    for dir in "$ASSETS_DIR"/*.imageset; do
      if [ -d "$dir" ]; then
        IMAGE_NAME=$(basename "$dir" .imageset)
        
        echo "    static let $IMAGE_NAME = UIImage(named: \"$IMAGE_NAME\")!" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
      fi
    done

    echo "}" >> "$OUTPUT_FILE"
}

load_colors
load_images

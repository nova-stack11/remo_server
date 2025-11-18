#!/bin/bash


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUNDLES_DIR="$BASE_DIR/../assets/bundles"
OUTPUT_DIR="$BASE_DIR/../public/bundles"
FINGERPRINT_FILE="$BASE_DIR/../public/assets_fingerprint.json"


mkdir -p $OUTPUT_DIR

MAPS_SRC="$BASE_DIR/../assets/bundles/maps"
MAPS_DST="$BASE_DIR/../public/maps"

echo "📁 Copying maps folder..."
rm -rf "$MAPS_DST"
mkdir -p "$MAPS_DST"
cp -R "$MAPS_SRC/" "$MAPS_DST/"

echo "{" > $FINGERPRINT_FILE
echo '  "bundles": {' >> $FINGERPRINT_FILE

first_entry=true

for bundle in $BUNDLES_DIR/*; do
  if [ -d "$bundle" ]; then
    name=$(basename "$bundle")
    zip_file="$OUTPUT_DIR/$name.bundle.zip"

    echo "📦 Creating bundle: $name"

    # Create ZIP
    cd "$bundle"
    zip -r "$OUTPUT_DIR/$name.bundle.zip" . > /dev/null
    cd - > /dev/null

    # Compute hash
    hash=$(shasum -a 256 "$zip_file" | awk '{ print $1 }')
    version=$hash

    if [ "$first_entry" = true ]; then
      first_entry=false
    else
      echo "," >> $FINGERPRINT_FILE
    fi

    echo "    \"$name\": { \"hash\": \"$hash\" }" >> $FINGERPRINT_FILE
  fi
done

echo "  }" >> $FINGERPRINT_FILE
echo "}" >> $FINGERPRINT_FILE

echo "🎉 Bundles built successfully!"
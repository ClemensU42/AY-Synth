set -e
mkdir -p build
cd build
cmake ..
make upload
cd ..

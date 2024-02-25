# Install Multiwfn
if [ -d "Multiwfn" ]; then
    echo "Multiwfn already installed"
else
    wget http://sobereva.com/multiwfn/misc/Multiwfn_3.8_dev_bin_Linux.zip
    unzip Multiwfn_3.8_dev_bin_Linux.zip
    mv Multiwfn_3.8_dev_bin_Linux Multiwfn
    rm Multiwfn_3.8_dev_bin_Linux.zip
fi
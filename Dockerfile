FROM tensorflow/tensorflow:2.10.1-jupyter

USER root

RUN apt-get update -y &&\
    apt-get install dpkg-dev cmake binutils libx11-dev libxpm-dev libxft-dev libxext-dev libssl-dev libxml2-dev libpcre3-dev libgtest-dev davix-dev -y &&\
    apt-get clean 

# Install required python packages
RUN python -m pip install pandas uproot seaborn scikit-learn tensorflow_probability==0.18.0 mplhep

# Install ROOT
RUN git clone --branch latest-stable --depth=1 https://github.com/root-project/root.git root_src
RUN mkdir root_build
RUN cmake -Dgminimal=ON -Dpyroot=ON -Ddataframe=ON -Dgnuinstall=ON -Ddev=ON \
          -Dbuiltin_xrootd=ON -Dxrootd=ON -Dbuiltin_davix=ON -Ddavix=ON  \
          -Dtmva=ON -Dmlp=ON -Dtmva-pymva=ON -Dtmva-cpu=ON -Dtmva-sofie=ON \
          -Dasimage=ON -Druntime_cxxmodules=ON \
          -B root_build -S root_src
RUN cmake --build root_build -- install -j$(nproc)
# Remove artifacts
RUN rm -rf root_build root_src

# Change environment so that libraries are properly found
RUN echo /usr/local/lib/root >> /etc/ld.so.conf && ldconfig
ENV PYTHONPATH /usr/local/lib/root:$PYTHONPATH
ENV CPPYY_BACKEND_LIBRARY /usr/local/lib/root/libcppyy_backend.so
ENV CLING_STANDARD_PCH none
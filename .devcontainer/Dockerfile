# --- Base Image ---
# Use the official ROS 2 Humble image as the foundation.
FROM ros:humble

# --- Environment Variables ---
# Set DEBIAN_FRONTEND to noninteractive to prevent apt-get from prompting for user input.
ENV DEBIAN_FRONTEND=noninteractive

# Set up the PATH to include local binaries for Rust (cargo) and Python (venv).
# This is crucial for making tools like `uv` and `cargo` available throughout the build.
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV VENV_PATH=/root/.venv
ENV PATH="/root/.local/bin:${CARGO_HOME}/bin:${VENV_PATH}/bin:${PATH}"

# --- System & Build Dependencies ---
# Install essential packages in a single layer to optimize caching.
# - build-essential: Compiler toolchain (gcc, g++, make).
# - git, wget, curl, unzip: Common tools for fetching source code and files.
# - clang, ripgrep: Useful developer tools (alternative compiler, fast search).
# - python3-*: Core ROS 2 tools for building and managing packages.
# After installation, clean up apt cache to reduce image size.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    clang \
    ripgrep \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-rosdep \
    python3-pip \
    python3-venv \
    ros-humble-mavros \
    && rm -rf /var/lib/apt/lists/*
SHELL [ "/bin/bash", "-c" ]
RUN source /opt/ros/humble/setup.bash && ros2 run mavros install_geographiclib_datasets.sh

# --- Developer Tooling Installation ---
# Install Rust, uv (Python package manager), and Neovim in a single RUN command.
# This keeps the development tools organized in one layer.
RUN \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path && \
    mkdir -p /opt/nvim && \
    wget -qO- "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz" | tar -xz -C /opt/nvim --strip-components=1 && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim

# --- Python Virtual Environment Setup ---
# Copy the requirements file and install dependencies into the virtual environment using uv.
# Because we added the venv path to the ENV PATH variable, we don't need to `source` the activate script.
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# --- ROS 2 Workspace Setup ---
# Set the working directory for the ROS 2 workspace.
WORKDIR /root/ros2_ws

# Copy ROS 2 repository definitions.
# Note: The original file included 'pkcs.patch', which was not used.
# If you need to apply a patch, you would add a command like:
# RUN git -C src/<your_repo> apply /tmp/additions/pkcs.patch
COPY repos.repos /tmp/
COPY colcon.meta .

# Create the 'src' directory and import repositories using vcstool.
RUN mkdir src && \
    vcs import src < /tmp/repos.repos

# --- ROS 2 Dependency Installation ---
# Install all ROS dependencies using rosdep. This is the standard way to ensure
# all required packages for your workspace are present.
RUN apt-get update && \
    rosdep init || true && \
    rosdep update && \
    rosdep install -y \
    --from-paths src \
    --ignore-src \
    --rosdistro humble -r \
    && rm -rf /var/lib/apt/lists/*

# --- Workspace Build (Optional) ---
# The following lines are commented out. Uncomment them if you want to create a
# pre-built image (e.g., for CI/CD or a non-development deployment).
# For a development container, it's better to build inside the running container.
# RUN . /opt/ros/humble/setup.sh && \
#     colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# --- Shell Configuration ---
# Configure the .bashrc file to automatically set up the environment
# for interactive sessions. This sources ROS, the Python venv, and sets up build aliases.
RUN echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc && \
    echo 'export CC=clang' >> /root/.bashrc && \
    echo 'export CXX=clang++' >> /root/.bashrc && \
    echo 'export BUILD_ARGS="--symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"' >> /root/.bashrc && \
    echo 'alias cb="colcon build ${BUILD_ARGS}"' >> /root/.bashrc && \
    echo 'alias cbt="colcon build --packages-select"' >> /root/.bashrc

# --- Entrypoint ---
# Start a bash shell when the container runs.
# The .bashrc configuration will be automatically sourced.
CMD [ "/bin/bash" ]

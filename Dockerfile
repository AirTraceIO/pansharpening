# Use Orfeo Toolbox image as the base
FROM orfeotoolbox/otb

# Install Python, pip, and other necessary packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# Install Flask
RUN pip3 install Flask

# Create the /otb directory
RUN mkdir -p /otb

# Copy all files from the current directory to /otb in the container
COPY . /otb

# Make the script executable and move it to a location in the PATH
RUN chmod +x /otb/otb.sh

# Flask application and exposed port
WORKDIR /otb
EXPOSE 5001

# Flask app to expose the functionality
COPY app.py /otb/app.py

# Define the entry point to run the Flask app
ENTRYPOINT ["python3", "app.py"]


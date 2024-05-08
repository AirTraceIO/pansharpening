Below is the content for a `README.md` file that explains step by step how to build and run the Docker container and how to make the `curl` call to the Flask API. This guide is designed to be comprehensive and user-friendly.

---

# Running the Orfeo Toolbox Docker Container with Flask API

This README provides detailed instructions on how to set up and run the Orfeo Toolbox Docker container, now enhanced with a Flask API that allows you to process images using a simple HTTP request. Follow these steps to get everything up and running.

## Prerequisites

Before you begin, ensure you have the following installed:
- **Docker**: You need Docker installed on your machine to build and run the Docker container. Visit [Docker's website](https://docs.docker.com/get-docker/) for installation instructions.
- **cURL**: cURL is used to make HTTP requests from the command line. It is likely already installed on your system, but if not, you can find installation instructions on the [cURL website](https://curl.se/download.html).

## Step 1: Build the Docker Image

Navigate to the directory containing your Dockerfile and run the following command to build your Docker image:

```bash
docker build -t otb:latest .
```

This command builds the Docker image and tags it as `otb:latest`.

## Step 4: Run the Docker Container

To run your Docker container with the Flask application, use the following command:

```bash
docker run -p 5001:5001 -v /path/to/your/otb_files:/otb_files otb
```

Make sure to replace `/path/to/your/otb_files` with the path to the directory containing your input TIFF image, the folder with the masks, and optionally the `response` folder.

## Step 5: Make the API Call

With the Docker container running, you can process images by sending a POST request to the Flask API. Here is an example using `curl`:

```bash
curl -X POST http://localhost:5001/processPansharp \
     -H "Content-Type: application/json" \
     -d '{
           "arg1": "/otb_files/file_zona3.tiff",
           "arg2": "/otb_files/zona3/050173540010_01_P001_PAN/20SEP27110053-P3DS-050173540010_01_P001.TIF",
           "arg3": "/otb_files/zona3/050173540010_01_P001_MUL/20SEP27110053-M3DS-050173540010_01_P001.TIF",
           "arg4": "/otb_files/response/secondTest.tif"
         }'
```

This command sends a JSON payload with four arguments to the Flask API, triggering the `otb.sh` script with these arguments.

## Troubleshooting

- **Permissions Issues**: If you encounter permissions issues with the mounted volume, ensure that the Docker user has the necessary permissions to access the `/otb_files` directory.
- **Dependency Errors**: If you see errors related to missing Python packages, ensure that you have correctly installed all required packages in your Dockerfile.
- **Networking Issues**: If you cannot reach the Flask app, make sure Docker is correctly mapping port 5001 to your host and that there are no firewall rules blocking this port.
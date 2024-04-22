FROM hashicorp/terraform:1.6

# Set a working directory
WORKDIR /app

# Define an entry point
# sudo docker build -t tf:16 .
# sudo docker run -it --rm --name tf -v $(pwd):/app tf:16 init
# sudo docker run -it --rm --name tf -v $(pwd):/app tf:16 plan
# sudo docker run -it --rm --name tf -v $(pwd):/app tf:16 apply
ENTRYPOINT ["/bin/terraform"]
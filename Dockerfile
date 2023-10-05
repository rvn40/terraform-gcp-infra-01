FROM hashicorp/terraform:1.6

# Set a working directory
WORKDIR /app

# Define an entry point
ENTRYPOINT ["/bin/terraform"]
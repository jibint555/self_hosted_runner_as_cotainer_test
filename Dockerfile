FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl sudo git jq build-essential libicu70 \
    && rm -rf /var/lib/apt/lists/*

# Add runner user
RUN useradd -m new-runner && echo "new-runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/new-runner
USER root
# Download GitHub Actions runner
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz

# Install .NET dependencies and ensure proper permissions as root
RUN ./bin/installdependencies.sh \
    && chown -R new-runner:new-runner /home/new-runner \
    && chmod -R 755 /home/new-runner

# Copy entrypoint script as root
COPY entrypoint.sh /home/new-runner/entrypoint.sh
RUN chmod +x /home/new-runner/entrypoint.sh

# Switch to runner user after all root work
USER new-runner

ENTRYPOINT ["/home/new-runner/entrypoint.sh"]

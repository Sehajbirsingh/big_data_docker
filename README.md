# Big Data Docker Environment

This project sets up a Big Data environment using Docker with Hadoop and Spark. It provides a simple way to run and test big data applications locally.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

### Clone the Repository

bash
git clone <repository-url>
cd big_data_docker


### Build and Run the Container

1. **Build the Docker image and start the services**:
   ```bash
   docker-compose up -d --build
   ```

2. **Check the status of the services**:
   ```bash
   docker exec -it namenode bash
   jps
   ```

3. **Access the web interfaces**:
   - Hadoop NameNode: [http://localhost:9870](http://localhost:9870)
   - YARN Resource Manager: [http://localhost:8088](http://localhost:8088)

### Adding Data

To add CSV or other data files for processing, place them in the `data` directory. This directory is mounted to `/data` inside the container.

### Stopping the Services

To stop the services, run:

bash
docker-compose down


### Troubleshooting

If you encounter issues, check the logs:

bash
docker-compose logs -f


### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
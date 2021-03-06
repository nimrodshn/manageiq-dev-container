# ManageIQ Developer Container

The 'ManageIQ Developer Container' is ment to serve developers working on ManageIQ(https://github.com/ManageIQ/manageiq) with making the development environment encapsulated, clean, and easy to setup.

### Prerequisites

To get started you will need:

- Download and install docker - https://docs.docker.com/engine/installation/linux/

- Clone the source code of ManageIQ to your local machine:

```
git clone https://github.com/ManageIQ/manageiq.git
```

### Getting Started

All we need to do is run the following commands:

```
docker build -t miq-dev-container .

docker run -p 3000:3000 -v your/local/manageiq:/manageiq/ miq-dev-container <plugin0> <plugin1> ...
```
It should take around 4-5 minutes for the image to be built and another 4-5 minutes for the application to initate the database and workers.

The ```docker run``` command accepts zero or more arguments as plugin to download (eg : ```manageiq-providers-amazon, manageiq-providers-azure``` etc..).

### Plugins Example

running ```docker run -p 3000:3000 -v your/local/manageiq:/manageiq/ miq-dev-container manageiq-providers-amazon``` will setup a miq-dev container with the manageiq-providers-amazon plugin built-in.



After the application was initiated - We are ready to develop!

To view the application all you need to do is open your favourite browser and enter:
```
http://localhost:3000
```


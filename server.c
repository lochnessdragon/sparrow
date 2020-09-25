#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h> // inet_addr
#include <unistd.h>    // write and sleep
#include <pthread.h>

/**
* Encapsulates the properties of the server.
*/
typedef struct server {
	// file descriptor of the soket in 
	// passive mode to wait for connections
	int listen_fd;
} server_t;

/**
* Encapsulates a thread
*/

typedef struct thread_pool {
	size_t thread_count;
} ThreadPool;

ThreadPool *tpool_create(size_t num)
{
	ThreadPool *tm;
	pthread_t thread;
	size_t i;

	if (num == 0)
		num = 2;

	tm = calloc(1, sizeof(*tm));
	tm->thread_count = num;

	
}

/**
 * Creates a socket for the server and makes it passive such that
 * we can wait for connections on it later.
 */
int server_listen(server_t* server);


/**
 * Accepts new connections and then prints `Hello World` to
 * them.
 */
int server_accept(server_t* server);


/**
* Return http stuff
*/
int http_server(int connection);

/**
 * Main server routine.
 *
 *      -       instantiates a new server structure that holds the
 *              properties of our server;
 *      -       creates a socket and makes it passive with
 *              `server_listen`;
 *      -       accepts new connections on the server socket.
 *
 */

#define PORT 8080
#define MAX_BACKLOG 50
#define MAX_THREADS 50

int main() {
	printf("HTTP Server starting...\n");

	int err = 0;
	server_t server = { 0 };

	err = server_listen(&server);
	if (err) {
		printf("Failed to listen on address 0.0.0.0:%c \n", PORT);
		return err;
	}

	int connection = 0;

	connection = server_accept(&server);
	if (connection < 0) {
		printf("Failed accepting connection\n");
		err = 1;
		return err;
	}

	int bytes = http_server(connection);
	
	if(bytes < 0) {
		printf("Could not write bytes.\n");
		err = 1;
		return err;
	}
	printf("Wrote %d bytes.\n", bytes);
	close(connection);
	
	close(server.listen_fd);
	return err;
}

int server_listen(server_t* server) {
	server->listen_fd = socket(AF_INET, SOCK_STREAM, 0);

	struct sockaddr_in server_addr;

	if(server->listen_fd == -1) {
		printf("Could not start server!\n");
		return 1;
	} else {
		printf("Socket created successfully!\n");
	}

	// prepare the sockaddr_in structure
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = INADDR_ANY;
	server_addr.sin_port = htons ( PORT );

	// bind
	if ( bind(server->listen_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
		printf("Bind failed.\n");
		return 1;
	} 

	printf("Binded successfully!\n");

	// set server to listen
	if ((listen(server->listen_fd, MAX_BACKLOG)) != 0) {
		printf("Could not set to listen.\n");
		return 1;
	}

	printf("Set listening mode correctly.\n");

	return 0;
}

int server_accept(server_t* server) {
	struct sockaddr_in client_addr;
	int len = sizeof(client_addr);
	int connection_fd = accept(server->listen_fd, (struct sockaddr *)&client_addr, &len);

	if(connection_fd < 0) {
		printf("Connection failed...\n");
		return -1;
	}
	printf("Server accepted the clent...\n");

	return connection_fd;	
}

/**
* Handle the request
*/
int http_server(int connection) {
	char read_buf[1024] = {0};

	int valread = read( connection, read_buf, 1024 );
	printf("%s\n", read_buf);
	if(valread < 0) 
	{
		printf("No bytes to read.");
	}

	char msg[77] = "HTTP/1.1 200 OK\nContent-Type: text/plain\nContent-Length: 12\n\nHello World!";
	//char * msg_body = "<html><body><p>Status: 200 OK</p></body></html>";
	
	// send buffer to client
	int error = write(connection, msg, sizeof(msg));

	return error;
}
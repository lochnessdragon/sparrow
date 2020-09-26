#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h> // inet_addr
#include <unistd.h>    // write and sleep
#include <pthread.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <errno.h>

// global variables
static volatile int running = 1;

void intHandler(int dummy) {
	running = 0;
}

typedef void (*thread_func_t)(void *arg);

/**
* Encapsulates the properties of the server.
*/
typedef struct server {
	// file descriptor of the soket in 
	// passive mode to wait for connections
	int listen_fd;
} server_t;


// HTTP Structures
struct request {
	char * method;
	char * filename;
};

struct response {
	int status_code;
	char * content_type;
	long content_length;
	char * data;
};

/**
* Encapsulates work for the threadpool to do
*/

typedef struct tpool_work {
	thread_func_t func;
	void * arg;
	struct tpool_work * next;
} tpool_work_t;

/**
* Encapsulates a thread pool
*/

typedef struct thread_pool {
	tpool_work_t *work_first;
	tpool_work_t *work_last;
	pthread_mutex_t work_mutex;
	pthread_cond_t work_cond;
	pthread_cond_t working_cond;
	size_t working_count;
	size_t thread_count;
	bool stop;
} ThreadPool;

/**
* Thread Work Data Object Methods
*/
tpool_work_t *tpool_work_create(thread_func_t function, void * arg) 
{
	tpool_work_t * work;

	if (function == NULL) 
		return NULL;

	work = malloc(sizeof(*work));
	work->func = function;
	work->arg = arg;
	work->next = NULL;
	return work;
}

void tpool_work_destroy(tpool_work_t * work) 
{
	if (work == NULL)
		return;
	free(work);
}

tpool_work_t * tpool_work_get(ThreadPool *tm)
{
	tpool_work_t *work;

	if (tm == NULL)
		return NULL;

	work = tm->work_first;
	if(work == NULL)
		return NULL;

	if (work->next == NULL) {
		tm->work_first = NULL;
		tm->work_last = NULL;
	} else {
		tm->work_first = work->next;
	}

	return work;
}

/**
* THe Worker Function
*/
void * tpool_worker(void * arg)
{
	ThreadPool *tm = arg;
	tpool_work_t * work;

	while(1) {
		pthread_mutex_lock(&(tm->work_mutex));

		while (tm->work_first == NULL && !tm->stop)
			pthread_cond_wait(&(tm->work_cond), &(tm->work_mutex));

		if (tm->stop)
			break;

		work = tpool_work_get(tm);
		tm->working_count++;
		pthread_mutex_unlock(&(tm->work_mutex));

		if (work != NULL) {
			work->func(work->arg);
			tpool_work_destroy(work);
		}

		pthread_mutex_lock(&(tm->work_mutex));
		tm->working_count--;
		if(!tm->stop && tm->working_count == 0 && tm->work_first == NULL)
			pthread_cond_signal(&(tm->working_cond));
		pthread_mutex_unlock(&(tm->work_mutex));
	}

	tm->thread_count--;
	pthread_cond_signal(&(tm->working_cond));
	pthread_mutex_unlock(&(tm->work_mutex));
	return NULL;
}

/**
* Creates a Thread Pool 
*/

ThreadPool *tpool_create(size_t num)
{
	ThreadPool *tm;
	pthread_t thread;
	size_t i;

	if (num == 0)
		num = 2;

	tm = calloc(1, sizeof(*tm));
	tm->thread_count = num;

	pthread_mutex_init(&(tm->work_mutex), NULL);
	pthread_cond_init(&(tm->work_cond), NULL);
	pthread_cond_init(&(tm->working_cond), NULL);
	
	tm->work_first = NULL;
	tm->work_last = NULL;

	for(i=0; i<num; i++) {
		pthread_create(&thread, NULL, tpool_worker, tm);
		pthread_detach(thread);
	}

	return tm;
}

bool tpool_add_work(ThreadPool *tm, thread_func_t func, void *arg)
{
    tpool_work_t *work;

    if (tm == NULL)
        return false;

    work = tpool_work_create(func, arg);
    if (work == NULL)
        return false;

    pthread_mutex_lock(&(tm->work_mutex));
    if (tm->work_first == NULL) {
        tm->work_first = work;
        tm->work_last  = tm->work_first;
    } else {
        tm->work_last->next = work;
        tm->work_last       = work;
    }

    pthread_cond_broadcast(&(tm->work_cond));
    pthread_mutex_unlock(&(tm->work_mutex));

    return true;
}

void tpool_wait(ThreadPool *tm)
{
    if (tm == NULL)
        return;

    pthread_mutex_lock(&(tm->work_mutex));
    while (1) {
        if ((!tm->stop && tm->working_count != 0) || (tm->stop && tm->thread_count != 0)) {
            pthread_cond_wait(&(tm->working_cond), &(tm->work_mutex));
        } else {
            break;
        }
    }
    pthread_mutex_unlock(&(tm->work_mutex));
}

void tpool_destroy(ThreadPool * tm)
{
	tpool_work_t *work;
	tpool_work_t *work2;

	if (tm == NULL) 
		return;

	pthread_mutex_lock(&(tm->work_mutex));
	work = tm->work_first;
	while(work != NULL) {
		work2 = work->next;
		tpool_work_destroy(work);
		work = work2;
	}

	tm->stop = true;
	pthread_cond_broadcast(&(tm->work_cond));
	pthread_mutex_unlock(&(tm->work_mutex));

	tpool_wait(tm);

	pthread_mutex_destroy(&(tm->work_mutex));
	pthread_cond_destroy(&(tm->work_cond));
	pthread_cond_destroy(&(tm->working_cond));

	free(tm);
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
void handle_http(void * args);

/*
* reads a request
*/
struct request read_request(const char * buffer);

/*
* sends a response
*/

int send_response(const struct response response_data, const int connection);

/**
* Loads a file into memory and passes a pointer to it.
*/

void load_file(const char * filename, long * fsize, char ** buffer);

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
#define MAX_THREADS 4

// the time before a socket is closed.
#define TIMEOUT 30

int main() {
	//signal(SIGINT, intHandler);

	printf("Sparrow Version 1.1\n");
	printf("HTTP Server starting...\n");

	ThreadPool *tm;

	tm = tpool_create(MAX_THREADS);

	// initlialize the thread that will take cli commands
	//pthread_t commands_thread;



	int err = 0;
	server_t server = { 0 };

	err = server_listen(&server);
	if (err) {
		printf("Failed to listen on address 0.0.0.0:%d \n", PORT);
		perror("Failed");
		return err;
	}

	while(running) {
		int * connection_ptr;

		connection_ptr = malloc(sizeof(connection_ptr));

		*connection_ptr = server_accept(&server);

		if (*connection_ptr < 0) {
			printf("Failed accepting connection\n");
			err = 1;
			break;
		}

		tpool_add_work(tm, handle_http, connection_ptr);
	}
	
	/*int bytes = handle_http(connection);
	
	if(bytes < 0) {
		printf("Could not write bytes.\n");
		err = 1;
		return err;
	}
	printf("Wrote %d bytes.\n", bytes);
	close(connection);*/

	printf("Cleaning up");

	tpool_destroy(tm);
	
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
	printf("Server accepted the client...\n");

	return connection_fd;	
}

// error messages
#define MSG_404 " 404 Not Found\nContent-Type: text/plain\nContent-Length: 14\n\n404 Not found!"
#define MSG_501 " 501 Not Implemented\nContent-Type: text/plain\nContent-Length: 20\n\n501 Not implemented!"

/**
* Handle the request
* 200 = OK
* 501 = Not Implemented
*/
void handle_http(void * args) {
	printf("Process ID: %ld\n", (long) getpid());

	int* val = args;

	// extract the connection from val
	int connection = *val;

	// the buffer to read into
	char read_buf[1024] = {0};

	int valread = read( connection, read_buf, 1024 );
	printf("%s\n", read_buf);
		
	if(valread <= 0) 
	{
		printf("No bytes to read.\n");
		close(connection);
		return;
	}

	printf("Read: %d\nGetting request and response data.\n", valread);

	// read the buffer, so make a struct to hold request and result
	struct request request_data = read_request(read_buf);
	struct response response_data;

	//char * msg = calloc(9, sizeof(char)); // allocate array to store msg. Header + body currently set to HTTP/1.1

	//strncpy(msg, "HTTP/1.1", 8);
	// process response

	// read the method
	if(strncmp(request_data.method, "GET", 3) == 0) {
		// get request, we can handle that.
		printf("GET request\n");

		// read in the resource to get

		// get the string containing the resource from / to ?
		//printf("File: %s Access: %d\n", request_data.filename, access(request_data.filename, F_OK | R_OK));

		long fsize = 0;

		char * file_buffer = NULL; 
		load_file(request_data.filename, &fsize, &file_buffer);

		if(file_buffer != NULL) { 

			char * file_encoding;

			// if the filename contains .png, then the type is image/webp
			if(strstr(request_data.filename, ".png") != NULL) {
				file_encoding = calloc(sizeof("image/png"), sizeof(char));
				strncpy(file_encoding, "image/png", sizeof("image/png"));
			} else if(strstr(request_data.filename, ".jpeg") != NULL) {
				file_encoding = calloc(sizeof("image/jpeg"), sizeof(char));
				strncpy(file_encoding, "image/jpeg", sizeof("image/jpeg"));
			}  else if(strstr(request_data.filename, ".jpg") != NULL) {
				file_encoding = calloc(sizeof("image/jpg"), sizeof(char));
				strncpy(file_encoding, "image/jpg", sizeof("image/jpg"));
			} else if(strstr(request_data.filename, ".gif") != NULL) {
				file_encoding = calloc(sizeof("image/gif"), sizeof(char));
				strncpy(file_encoding, "image/gif", sizeof("image/gif"));
			} else if (strstr(request_data.filename, ".html") != NULL) {
				// else it is text/html
				file_encoding = calloc(sizeof("text/html"), sizeof(char));
				strncpy(file_encoding, "text/html", sizeof("text/html"));
			} else if (strstr(request_data.filename, ".css") != NULL) {
				// else it is text/css
				file_encoding = calloc(sizeof("text/css"), sizeof(char));
				strncpy(file_encoding, "text/css", sizeof("text/css"));
			} else if (strstr(request_data.filename, ".js") != NULL) {
				// else it is text/js
				file_encoding = calloc(sizeof("text/js"), sizeof(char));
				strncpy(file_encoding, "text/js", sizeof("text/js"));
			} else {
				// else it is text/plain
				file_encoding = calloc(sizeof("text/plain"), sizeof(char));
				strncpy(file_encoding, "text/plain", sizeof("text/plain"));
			}

			response_data.content_type = file_encoding;
			response_data.content_length = fsize;
			response_data.status_code = 200;
			response_data.data = file_buffer;

			/*char * extra_headers = calloc(41 + strlen(file_encoding) + sizeof(long), sizeof(char));

			sprintf(extra_headers, " 200 OK\nContent-Type: %s\nContent-Length: %ld\n\n", file_encoding, fsize);
			*/

			// add response headers
			/*msg = realloc(msg, (sizeof(char) * (strlen(msg) + strlen(extra_headers) + strlen(file_buffer) + 1)));
			strcat(msg, extra_headers);
			strncat(msg, file_buffer, fsize);*/

			//free(file_buffer);

		} else {
			char * error_404 = calloc(sizeof("404 Not found") + 1, sizeof(char));
			strncpy(error_404, "404 Not found", sizeof("404 Not found"));

			char * content_t_404 = calloc(sizeof("text/plain") + 1, sizeof(char));
			strncpy(content_t_404, "text/plain", sizeof("text/plain"));

			response_data.content_type = content_t_404;
			response_data.content_length = strlen(error_404);
			response_data.status_code = 404;
			response_data.data = error_404;
		}

	} else {
		// unimplemented, will get to it soon.
		/*write(connection, "HTTP/1.1 501 Not Implemented", 28);
			sync();
			continue;*/			
			char * error_501 = calloc(sizeof("501 Not implemented") + 1, sizeof(char));
			strncpy(error_501, "501 Not implemented", sizeof("501 Not implemented"));

			char * content_t_501 = calloc(sizeof("text/plain") + 1, sizeof(char));
			strncpy(content_t_501, "text/plain", sizeof("text/plain"));

			response_data.content_type = content_t_501;
			response_data.content_length = strlen(error_501);
			response_data.status_code = 501;
			response_data.data = error_501;
	}

	// process response
	//char msg[76] = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: 12\n\nHello World!";
	
	// send buffer to client
	//int error = write(connection, msg, strlen(msg));
	int error = send_response(response_data, connection);
	if(error == -1) {
		perror("Failed");
		printf("Error writing message\n");
	}
	//sync();

	printf("Cleaning up\n");
	// clean up by closing the connection and freeing the args
	close(connection);

	free(request_data.method);
	free(request_data.filename);

	free(response_data.content_type);
	free(response_data.data);

	free(args);
	//return error;
}


// has a method and filename
struct request read_request(const char * buffer) 
{
	struct request request_data = {NULL};

	char * method_end = strchr(buffer, ' ');

	request_data.method = calloc((method_end - buffer) + 1, sizeof(char));
	strncpy(request_data.method, buffer, (method_end - buffer));

	char * filename_beginning = strchr(buffer + strlen(request_data.method) + 1, '/');
	char * filename_end = strchr(buffer + strlen(request_data.method) + 1, ' ');

	request_data.filename = calloc((filename_end - filename_beginning) + sizeof("web") + 1, sizeof(char));
			
	strcpy(request_data.filename, "web");

	strncat(request_data.filename, buffer + strlen(request_data.method) + 1, (filename_end - filename_beginning));

	printf("Parsed Method: %s| Filename: %s|\n", request_data.method, request_data.filename);

	return request_data;
}

// response constists of status code, content length, content type, data
int send_response(const struct response response_data, const int connection) 
{
	//printf("Response: Content-Type: %s, Content-Length: %ld, Status Code: %d\n Response: %s", response_data.content_type, response_data.content_length, response_data.status_code, response_data.data);

	char * msg;

	// headers
	char * headers = calloc(sizeof("HTTP/1.1  OK\nContent-Type: \nContent-Length: \n\n") + strlen(response_data.content_type) + sizeof(long) + sizeof(int) + 1, sizeof(char));

	sprintf(headers, "HTTP/1.1 %d OK\nContent-Type: %s\nContent-Length: %ld\n\n", response_data.status_code, response_data.content_type, response_data.content_length);

	//printf("Headers: %s\n", headers);

	// allocatate msg and input reponse parts
	msg = calloc(strlen(headers) + response_data.content_length + 1, sizeof(char));
	strncpy(msg, headers, strlen(headers));

	memcpy(msg + strlen(headers), response_data.data, response_data.content_length);

	printf("Response: %s\nLength: %lu\n", msg, strlen(headers) + response_data.content_length);

	int bytes = write(connection, msg, strlen(headers) + response_data.content_length);
	
	free(headers);
	free(msg);

	return bytes;
}

void load_file(const char * filename, long * fsize, char ** buffer)
{
	char * file_buffer = NULL;

	if(access(filename, F_OK | R_OK) != -1) { 
		FILE* response_file = fopen(filename,"rb");
		//printf("File opened: %d\n", response_file == NULL);

		//printf("Getting size of file\n");
		fseek(response_file, 0, SEEK_END);
		*fsize = ftell(response_file);
		fseek(response_file, 0, SEEK_SET);  /* same as rewind(f); */

		printf("Size: %ld\n", (*fsize));

		//printf("Reading file into buffer\n");
		file_buffer = malloc((*fsize) + 1);
		fread(file_buffer, 1, (*fsize), response_file);

		fclose(response_file);

		//printf("Setting end of file buffer.\n");
		file_buffer[(*fsize)] = 0;

	} else {
		printf("Could not find file.\n");
		perror("Failed");
		errno = 0;
	}

	(*buffer) = file_buffer;
}
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/mman.h>
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

char * cgi_script(struct request request_data);

char * lua_script(struct request request_data);

/*
* reads a request
*/
struct request read_request(const char * buffer);

/*
* sends a response
*/

int send_response(const struct response response_data, const int connection);

struct response build_response(int status_code, char * response_type, char * data, long data_length);

char * get_error_msg(int status_code);

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
#define SERVER_ID "Sparrow/0.1"
#define BUFFER_SIZE 256

/**
* Main function
*/
int main() {
	printf("===============================================\n\t\tSparrow Version 0.1\n===============================================\n\n");
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

	while(1) {
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

/**
* Start the server on a port 
*/

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

/**
* Accept a connection
*/
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

/**
* Handle the request
* 200 = OK
* 501 = Not Implemented
* This method is called by a thread
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

		long data_size = 0;

		char * file_buffer = NULL; 
		if(strstr(request_data.filename, ".php") != NULL) {
			file_buffer = cgi_script(request_data);
		} else {
			load_file(request_data.filename, &data_size, &file_buffer);
		}

		if(file_buffer != NULL) { 

			//char * file_encoding;

			// if the filename contains .png, then the type is image/webp
			if(strstr(request_data.filename, ".png") != NULL) {
				// png image??
				response_data.content_type = "image/png";
			} else if(strstr(request_data.filename, ".jpeg") != NULL) {
				// jpeg image?
				response_data.content_type = "image/jpeg";
			}  else if(strstr(request_data.filename, ".jpg") != NULL) {
				// jpg image?
				response_data.content_type = "image/jpg";
			} else if(strstr(request_data.filename, ".gif") != NULL) {
				// gif image?
				response_data.content_type = "image/gif";
			} else if (strstr(request_data.filename, ".html") != NULL) {
				// else it is text/html
				response_data.content_type = "text/html";
			} else if (strstr(request_data.filename, ".css") != NULL) {
				// else it is text/css
				response_data.content_type = "text/css";
			} else if (strstr(request_data.filename, ".js") != NULL) {
				// else it is text/js
				response_data.content_type = "text/javascript";
			} else {
				// else it is text/plain
				response_data.content_type = "text/plain";
			}

			//response_data.content_type = file_encoding;
			response_data.content_length = data_size;
			response_data.status_code = 200;
			response_data.data = file_buffer;

		} else {
			response_data = build_response(404, "text/plain", "404 Not Found!", sizeof("404 Not Found!") - 1);
		}

	} else {	
			response_data = build_response(501, "text/plain", "501 Not Implemented!", sizeof("501 Not Implemented!") - 1);
	}

	// send the response
	int error = send_response(response_data, connection);
	if(error == -1) {
		perror("Failed");
		printf("Error writing message\n");
	}

	printf("Cleaning up\n");
	// clean up by closing the connection and freeing memory
	close(connection);

	free(request_data.method);
	free(request_data.filename);

	//free(response_data.content_type);
	if(response_data.status_code == 200)
		munmap(response_data.data, response_data.content_length);

	free(args);
	//return error;
}

/**
* Gets a request structure from a connection buffer
*/
// has a method and filename
struct request read_request(const char * buffer) 
{
	struct request request_data = {NULL};

	char * method_end = strchr(buffer, ' ');

	request_data.method = calloc((method_end - buffer) + 1, sizeof(char));
	strncpy(request_data.method, buffer, (method_end - buffer));

	char * filename_beginning = strchr(buffer + strlen(request_data.method) + 1, '/');
	char * filename_end = strchr(buffer + strlen(request_data.method) + 1, ' ');

	//printf("Filename End: %c\n", *(filename_end-1));

	if(*(filename_end-1) == '/') {
		// uh oh, its a directory
		printf("We think this is a directory, so we are going to return index.html\n");
		request_data.filename = calloc((filename_end - filename_beginning) + sizeof("web") + sizeof("index.html") + 1, sizeof(char));
			
		strcpy(request_data.filename, "web");

		strncat(request_data.filename, buffer + strlen(request_data.method) + 1, (filename_end - filename_beginning));

		strncat(request_data.filename, "index.html", sizeof("index.html"));

	} else {

		request_data.filename = calloc((filename_end - filename_beginning) + sizeof("web") + 1, sizeof(char));
			
		strcpy(request_data.filename, "web");

		strncat(request_data.filename, buffer + strlen(request_data.method) + 1, (filename_end - filename_beginning));
	}

	printf("Parsed Method: %s| Filename: %s|\n", request_data.method, request_data.filename);

	return request_data;
}

/**
* A helper method so that I don't have a lot of duplicate code
* 
*/
// response constists of status code, content length, content type, data
struct response build_response(int status_code, char * response_type, char * data, long data_length) 
{
	struct response response_data = {0};
	response_data.status_code = status_code;
	response_data.content_type = response_type;
	response_data.data = data;
	response_data.content_length = data_length;

	return response_data;
}
/**
* Formats and sends a reponse to a connection with the correct headers and data
*/
// response constists of status code, content length, content type, data
int send_response(const struct response response_data, const int connection) 
{
	//printf("Response: Content-Type: %s, Content-Length: %ld, Status Code: %d\n Response: %s", response_data.content_type, response_data.content_length, response_data.status_code, response_data.data);

	char * msg;

	// headers
	char * msg_code = get_error_msg(response_data.status_code);

	time_t now = time(&now);

	char date[BUFFER_SIZE];
	struct tm *time_data = gmtime(&now);

	strftime(date, BUFFER_SIZE, "%a, %m %b %G %T %Z", time_data);

	char * headers = calloc(sizeof("HTTP/1.1  \r\nServer: \r\nDate: \r\nContent-Type: \r\nContent-Length: \r\n\r\n") + sizeof(SERVER_ID) + strlen(response_data.content_type) + strlen(date) + strlen(msg_code) + sizeof(long) + sizeof(int) + 1, sizeof(char));

	sprintf(headers, "HTTP/1.1 %d %s\r\nServer: %s\r\nDate: %s\r\nContent-Type: %s\r\nContent-Length: %ld\r\n\r\n", response_data.status_code, msg_code, SERVER_ID, date, response_data.content_type, response_data.content_length);

	//printf("Headers: %s\n", headers);

	// allocatate msg and input reponse parts
	msg = calloc(strlen(headers) + response_data.content_length + 1, sizeof(char));
	strcpy(msg, headers);

	memcpy(msg + strlen(headers), response_data.data, response_data.content_length);

	//printf("Response: %s\nLength: %lu\n", msg, strlen(headers) + response_data.content_length);

	int bytes = write(connection, msg, strlen(headers) + response_data.content_length);
	
	free(headers);
	free(msg);

	return bytes;
}

/**
* Executes a cgi script with the filename in the request structure
*/

char * cgi_script(struct request request_data)
{
	printf("Executing cgi script: %s\n", request_data.filename);

	printf("Setting environment variables\n");
	//putenv("AUTH_TYPE="); // Authentication type
	putenv("CONTENT_LENGTH=NULL"); // Content Length
	//putenv("CONTENT_TYPE="); // Content Type
	putenv("GATEWAY_INTERFACE=CGI/1.1"); // Gateway Interface
	putenv("PATH_INFO=script.php"); // Path Info
	//putenv("PATH_TRANSLATED="); // Path Translated
	putenv("QUERY_STRING=\"\""); // Query String
	putenv("REMOTE_ADDR=127.0.0.1");
	putenv("REMOTE_HOST=NULL");
	//putenv("REMOTE_IDENT="); // Remote Identification
	//putenv("REMOTE_USER="); // Remote User
	putenv("REQUEST_METHOD=GET"); // Requested Method
	putenv("SCRIPT_NAME=/script.php"); // Script Name
	putenv("SERVER_NAME=localhost"); // Server Name

	char server_port[20];
	sprintf(server_port, "SERVER_PORT=%d", PORT);
	putenv(server_port); // Server Port

	putenv("SERVER_PROTOCOL=HTTP/1.1"); // Server Protocol
	putenv("SERVER_SOFTWARE=" 
	SERVER_ID); // Server Software
	putenv("REDIRECT_STATUS=CGI");
	putenv("SCRIPT_FILENAME=script.php");

	printf("Executing script now.\n");
	FILE *fp = popen("cd web && php-cgi -fscript.php", "r"); // change into directory and run the script

	if (fp == NULL) {
		printf("Failed to run command");
		return NULL;
	}

	printf("Response:\n");

	while(!feof(fp)) {
		printf("%c", fgetc(fp));
	}

	pclose(fp);


	return NULL;
}

char * lua_script(struct request request_data) 
{
	
}

/**
* Returns the http error description for a given status code
* Example: 404 = Not Found
* TODO: Refactor for cleaner 
*/
char * get_error_msg(int status_code) 
{
	switch(status_code) {
		case 100:
			return "Continue";
		case 101:
			return "Switching Protocols";
		case 102:
			return "Processing";
		case 103:
			return "Early Hints";
		case 200:
			return "OK";
		case 201:
			return "Created";
		case 202:
			return "Accepted";
		case 203:
			return "Non-Authoritative Information";
		case 204:
			return "No Content";
		case 205:
			return "Reset Content";
		case 206:
			return "Partial Content";
		case 207:
			return "Multi-Status";
		case 208:
			return "Already Reported";
		case 226:
			return "IM Used";
		case 300:
			return "Multiple Choices";
		case 301:
			return "Moved Permanently";
		case 302:
			return "Found";
		case 303:
			return "See Other";
		case 304:
			return "Not Modified";
		case 305:
			return "Use Proxy";
		case 306:
			return "Switch Proxy";
		case 307:
			return "Temporary Redirect";
		case 308:
			return "Permanent Redirect";
		case 400:
			return "Bad Request";
		case 401:
			return "Unauthorized";
		case 402:
			return "Payment Required";
		case 403:
			return "Forbidden";
		case 404:
			return "Not found";
		case 405:
			return "Method Not Allowed";
		case 406:
			return "Not Acceptable";
		case 407:
			return "Proxy Authentication Required";
		case 408:
			return "Request Timeout";
		case 409:
			return "Conflict";
		case 410:
			return "Gone";
		case 411:
			return "Length Required";
		case 412:
			return "Precondition Failed";
		case 413:
			return "Payload Too Large";
		case 414:
			return "URI Too Long";
		case 415:
			return "Unsupported Media Type";
		case 416:
			return "Range Not Satisfiable";
		case 417:
			return "Expectation Failed";
		case 418:
			return "I'm a teapot";
		case 421:
			return "Misdirected Request";
		case 422:
			return "Unprocessable Entity";
		case 423:
			return "Locked";
		case 424:
			return "Failed Dependency";
		case 425:
			return "Too Early";
		case 426:
			return "Upgrade Required";
		case 428:
			return "Precondition Required";
		case 429:
			return "Too Many Requests";
		case 431:
			return "Request Header Fields Too Large";
		case 451:
			return "Unavailable for Legal Reasons";
		case 500:
			return "Internal Server Error";
		case 501:
			return "Not Implemented!";
		case 502:
			return "Bad Gateway";
		case 503:
			return "Service Unavailable";
		case 504:
			return "Gateway Timeout";
		case 505:
			return "HTTP Version Not Supported";
		case 506:
			return "Variant Also Negotiates";
		case 507:
			return "Insufficient Storage";
		case 508:
			return "Loop Detected";
		case 510:
			return "Not Extended";
		case 511:
			return "Network Authentication Required";
		default:
			return "Unknown";
	}
}

void load_file(const char * filename, long * fsize, char ** buffer)
{	

	if(access(filename, F_OK | R_OK) != -1) { 
		FILE* response_file = fopen(filename,"rb");
		//printf("File opened: %d\n", response_file == NULL);

		//printf("Getting size of file\n");
		fseek(response_file, 0, SEEK_END);
		*fsize = ftell(response_file);
		fseek(response_file, 0, SEEK_SET);  /* same as rewind(f); */

		printf("Size: %ld\n", (*fsize));

		//printf("Reading file into buffer\n");
		(*buffer) = mmap(NULL, (*fsize), PROT_READ, MAP_PRIVATE, fileno(response_file), 0);
		//fread(file_buffer, 1, (*fsize), response_file);

		fclose(response_file);

		//printf("Setting end of file buffer.\n");
		//file_buffer[(*fsize)] = 0;

	} else {
		(*buffer) = NULL;	
		printf("Could not find file.\n");
		perror("Failed");
		errno = 0;
	}
}
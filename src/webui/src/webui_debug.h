#include <kore.h>
#include <http.h>
#include <attributes_set.h>

#ifndef _WEBUI_DEBUG_H
#define _WEBUI_DEBUG_H
#ifndef __where_i_am__
static uint8_t __buf_where_i_am__[256];

#define __where_i_am__\
	(\
		snprintf(__buf_where_i_am__,sizeof(__buf_where_i_am__),"%s:%d:1 '%s'",__FILE__,__LINE__,__func__)?\
				__buf_where_i_am__:__buf_where_i_am__)
	/* TODO Stack trace format in tmp directory ? */

#endif


#define __WEBUI_DEBUG__
#ifndef __WEBUI_DEBUG__
#define WEBUI_DEBUG {}
#else
#define WEBUI_DEBUG {fprintf(stderr,"WEBUI_DEBUG: %s\n",__where_i_am__);}
#endif

/* Define mapping with bootstap alert level */
#define WEBUI_level_error (char*)"danger"
#define WEBUI_level_warning (char*)"warning"
#define WEBUI_level_info (char*)"info"
#define WEBUI_level_success (char*)"success"

/* Definition of function and prototype for add message to TMPL_LOOP */
void _webui_add_message_level(attributes_set_t *ptr_attrl,const char*level,const char *log_message);

#define WEBUI_DEF_ERROR_LEVEL_MESSAGE_PROTOTYPE(LEVEL) \
    void webui_add_ ## LEVEL ## _message  (attributes_set_t *ptr_attrl,const char *log_message) ;

WEBUI_DEF_ERROR_LEVEL_MESSAGE_PROTOTYPE(info) ;
WEBUI_DEF_ERROR_LEVEL_MESSAGE_PROTOTYPE(warning) ;
WEBUI_DEF_ERROR_LEVEL_MESSAGE_PROTOTYPE(success) ;
WEBUI_DEF_ERROR_LEVEL_MESSAGE_PROTOTYPE(error);


#define WEBUI_DEF_ERROR_LEVEL_MESSAGE(LEVEL) \
        void webui_add_ ## LEVEL ## _message (attributes_set_t *ptr_attrl,const char *log_message) \
            { _webui_add_message_level(ptr_attrl, WEBUI_level_ ##LEVEL ,log_message); }
/**/

#define TMPL_VAR_LEVEL_MESSAGE "level"
#define TMPL_VAR_TEXT_MESSAGE "text"

#define TMPL_VAR_MESSAGE_LOOP "message_loop"

/* TODO aggiungere stacktrace debug */
#endif

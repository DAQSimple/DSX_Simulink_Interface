function DSX_data_t()

typedef struct {
   unsigned int ID   	:7;
   unsigned int loc  	:6;
   unsigned int sign    :1;
   unsigned int val  	:14;
   unsigned int ret  	:4;  }DSX_data_t

end
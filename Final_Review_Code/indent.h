#define stack_size 200

typedef struct stack{
		int arr[stack_size];
		int stack_pointer;
	}stack;

extern stack tab_stack;
extern int top(stack *);
extern void pop(stack *);
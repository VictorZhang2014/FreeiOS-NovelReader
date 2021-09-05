//
//  main.m
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/1/29.
//

#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "AppDelegate.h"


typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
 
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif
 
void DenyAppAttach() {
    void * handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}


int main(int argc, char * argv[]) {
    
#ifndef DEBUG
    DenyAppAttach();
#endif
    
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

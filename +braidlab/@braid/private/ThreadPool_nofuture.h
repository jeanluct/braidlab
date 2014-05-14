/*
A simple implementation of a Thread Pool based on Jakob Progsch's
implementation.

Thread pools instantiate N worker-threads, optimally N <= # parallel
processing cores, and pass tasks (which might be numerous) to them,
ensuring that workers take up new tasks only as they complete previous
tasks.

MODIFIED by Marko Budisic to remove dependence on std::future
therefore allowing compatibility with GCC 4.4. The downside is that
this version does not support return values from tasks.

See: http://progsch.net/wordpress/?p=81
https://github.com/progschj/ThreadPool/commit/20061c5c7fc64f9bfe2f5852ad5551e4adf379ad

Implementation downloaded on May 13, 2014 under the following license:

Copyright (c) 2012 Jakob Progsch

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
*/

#ifndef THREAD_POOL_H
#define THREAD_POOL_H

#include <vector>
#include <queue>
#include <memory>
#include <thread>
#include <mutex>
#include <condition_variable>
// M.Budisic: remove dependence on future by removing the feature
// that returns the task results
//#include <future>
#include <functional>
#include <stdexcept>

class ThreadPool {
public:
  ThreadPool(size_t);
    // M.Budisic: remove dependence on future by removing the feature
    // that returns the task results
    /* template<class F, class... Args> */
    /* auto enqueue(F&& f, Args&&... args)  */
    /*   -> std::future<typename std::result_of<F(Args...)>::type>; */
    template<class F, class... Args>
      void enqueue(F&& f, Args&&... args);
    ~ThreadPool();
private:
    // need to keep track of threads so we can join them
    std::vector< std::thread > workers;
    // the task queue
    std::queue< std::function<void()> > tasks;
    
    // synchronization
    std::mutex queue_mutex;
    std::condition_variable condition;
    bool stop;
};
 
// the constructor just launches some amount of workers
inline ThreadPool::ThreadPool(size_t threads)
    :   stop(false)
{
    for(size_t i = 0;i<threads;++i)
        workers.emplace_back(
            [this]
            {
                for(;;)
                {
                    std::unique_lock<std::mutex> lock(this->queue_mutex);
                    while(!this->stop && this->tasks.empty())
                        this->condition.wait(lock);
                    if(this->stop && this->tasks.empty())
                        return;
                    std::function<void()> task(this->tasks.front());
                    this->tasks.pop();
                    lock.unlock();
                    task();
                }
            }
        );
}


// M.Budisic: remove dependence on future by removing the feature
// that returns the task results

/* template<class F, class... Args> */
/* auto ThreadPool::enqueue(F&& f, Args&&... args)  */
/*     -> std::future<typename std::result_of<F(Args...)>::type> */

// add new work item to the pool
template<class F, class... Args>
void ThreadPool::enqueue(F&& f, Args&&... args) 
{
    typedef typename std::result_of<F(Args...)>::type return_type;
    
    // don't allow enqueueing after stopping the pool
    if(stop)
        throw std::runtime_error("enqueue on stopped ThreadPool");

    /* auto task = std::make_shared< std::packaged_task<return_type()> > */
    /*   (std::bind(std::forward<F>(f), std::forward<Args>(args)...)); */
    
    auto task = std::bind(std::forward<F>(f), std::forward<Args>(args)...);
    
    // M.Budisic: remove dependence on future by removing the feature
    // that returns the task results
    //    std::future<return_type> res = task->get_future(); 
    {
        std::unique_lock<std::mutex> lock(queue_mutex);
        tasks.push([task](){ task(); });
    }
    condition.notify_one();
    //    return res;
    return;
}

// the destructor joins all threads
inline ThreadPool::~ThreadPool()
{
    {
        std::unique_lock<std::mutex> lock(queue_mutex);
        stop = true;
    }
    condition.notify_all();
    for(size_t i = 0;i<workers.size();++i)
        workers[i].join();
}

#endif

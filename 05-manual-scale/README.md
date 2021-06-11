# Manual pod scaling - without loosing requests

Simple Kubernetes tutorials deal not with scenarios, where scale up or scale down actions occur without loosing requests. There are several things to observe:

- a service has to be ready before starting to serve requests
- a service has to finish its in-flight requests before shutting down
- Kubernetes is a highly distributed system with limited orchestration. This means, we have to ensure some things for ourselves.
- We need some testbed and load to verify our assumptions

## Challenges

So we have several challenges to simulate in out server and to solve such that Kubernetes does not generate errors.

### Simulating a startup time for our service

We added a default time.Sleep of 25 seconds to the hello service, see [hello.go at line 43](./hello.go). This means that the server only starts serving requests after the startup period is finished. This simulates a startup time that should be respected.

### Simulating long running requests

We added a default time.Sleep of 5 seconds to the hello endpoint, see [hello.go at line 77](./hello.go). This means that the server serves the request but it takes three seconds to complete. This simulates long running requests that should not fail.

### Simulating load

There is a Makefile target named load that generates some "load" on the service. To be honest, the service is able to deliver much more requests per second, but for this demo the load is more than enough. We use a classic `ab` ([see doc](https://httpd.apache.org/docs/2.4/programs/ab.html)) for generating load.

The load is generated using a docker container:

```bash
docker run 
```

## Scale Up

Scale up only works error free, when there are `liveness` and `readyness` probes correctly configured. See the [documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) for details about how to configure such a probe.

To have those probes working, you have to specify an endpoint that accepts these requests. Note that readyness and liveness endpoints should be two different endpoints in real world applications. In the example we added the `/status` endpoint in [hello.go at line 21 and line 53](./hello.go).

The deployment has to have those two probes configured for scaling up without getting errors. Note the `initialDelaySeconds` that is set to 20 seconds and the frequency is specified in `periodSeconds` with 10 seconds. Remember that we implemented a startup time of at least 25 seconds, so the first probe is going to fail and the pod is staying unready till the second probe hits. Only after the probe succeeds, traffic is going to be routed to the pod.

If the probe would fail a second time, the pod would get restarted.

## Scale Down

The scale down scenario is more complicated. We have to care about a several things:

- Graceful Shutdown of pod (take care of in-flight requests)
- 'Orchestrate' the phasing out of the service and its pod
- Configure correct grace period for shutdown of pod, after that period the pod is killed and requests are lost

### Graceful Shutdown



### Orchestrate service and pod

TODO:

[delaying shutdown to wait for pod deletion propagation](https://blog.gruntwork.io/delaying-shutdown-to-wait-for-pod-deletion-propagation-445f779a8304)

[original comment in issue regarding pod deletion propagation](https://github.com/kubernetes/kubernetes/issues/43576#issuecomment-297853203)

### Configure correct grace period

The configuration parameter `terminationGracePeriodSeconds` of a pod contains the number of seconds that a pod is killed, after the `SIGTERM` signal was sent to the process. In the optimal configuration this is longer than the configured graceful shutdown time added to the length of the configured `preStop` Hook. Only then the pod is guaranteed to have received the `SIGTERM` signal and the graceful shutdown can be finished.
When the `terminationGracePeriodSeconds` has expired, the kubernetes controller sends a `SIGKILL` to the processes/container in the pod and the processes are forcefully shut down.

## Takeaways

So, here are some key takeaways:

- If you see errors in scaling up:
  - Check if there is a service instance ready and alive
  - Check your `liveness` and `readyness` probes if they are configured correctly

- If you see errors in scaling down:
  - Check, if the service has a graceful shutdown and check the configured time (t1)
  - Check, if the service has a `preStopHook` with some sleep configured (5 or more seconds, t2)
  - Check, if the `terminationGracePeriodSeconds` (t3) is at least greater than the sum of the graceful shutdown time of the service and the time of the preStopHook (t3 > t1+t2)
  - Check, if the process in the container is running on PID 1. If it is not, you can is probable that the process in the container does not get the `SIGTERM` and `SIGKILL` signals and is therefore not _aware_ of a shutdown going on

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

# Six Errors in Kubernetes Deployments

This is a collection of Kubernetes deployment specification errors that are necessary to understand to specify pods that do not loose requests while scaling. You will not see those in "Hello World" examples...

1. **PID 1 Problem**: This is not an original Kubernetes problem, but nonetheless this is a problem can be observed often: In each container there should be one process and only one process and this process has to run with PID 1 and nothing else. If it does not run with PID 1, it will not receive `SIGTERM` or `SIGKILL` signals. ([Link to Docker](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#cmd), [Link to Kubernetes](https://cloud.google.com/architecture/best-practices-for-building-containers))
2. **PreStop Hook**: A well known fact is that you define everything in Kubernetes declarative. This means that you define a state and Kubernetes tries to achieve this state. Because Kubernetes is a highly distributed system and lots of components have to change, e.g. when scaling a pod (routing, scheduling, execution just to name a few). Because Kubernetes does not care about orchestration, just about observing the changes between desired state and current state and execution of necessary actions. This can lead to problems when scale actions happen, because sometimes the pod shutdown is initiated, but the service using that pod is still in place and did not yet receive its action from the designated controller.
Because of that it is _best practice_ (or better called a workaround) to define a `preStopHook` in the pod spec with a delay of some seconds to not loose requests in scaling down. ([Link to Kubernetes issue 1](https://github.com/kubernetes/kubernetes/issues/43576), [Link to Kubernetes issue 2](https://github.com/kubernetes-retired/contrib/issues/1140#issuecomment-231641402))
3. **Liveness and Readyness probes**: When scaling up, a pod only receives requests, when its readyness probes succeed. You can tweak those delays and frequencies with `initialDelaySeconds`, `periodSeconds` and `failureThreshold` (do not forget, if needed: `successThreshold` and `timeoutSeconds`). They should only show as failed, when the pod really is not healthy or is not able to start up as defined. ([Link to Kubernetes doc](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes))
4. **Graceful Shutdown**: When signal `SIGTERM` is received, a pod should mark itself as no longer ready and initiate shutdown. It should stop accepting new requests and finish processing all remaining _in flight requests_. Every major language (Java, Go, etc.) and middleware (NginX, Apache, etc.) support graceful shutdown, just search for _graceful shutdown_. ([Link to Kubernetes pod lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes))
5. **Orchestrate Timeouts when shutting down**: When a shutdown is scheduled, be it either a scale down or a rolling upgrade, several timeouts come into play:

    1. `preStopHook` of pod: Should be at least some seconds, see section for preStopHook. Only after this hook is executed, the `SIGTERM` signal is going to be sent to the pod.
    2. `gracefulShutdown` of app: Is configured as the time that the app is allowed to consume to shut down in-flight requests. This is an app specific setting and is normally not found in the Kubernetes deployment descriptor (unless you configured it using an environment variable, of course)
    3. `terminationGracePeriodSeconds` of pod: After this period of seconds the pod will get killed forcefully using signal `SIGKILL`. The setting has to be larger than `preStopHook` sleep time added to the `gracefulShutdown` time of the app, see the previous two bullets. You should also compensate for some delays and allocate some buffer time (several seconds at least).

    So, TL;DR:

    ```calc
    preStopHook sleep (pod spec) + gracefulShutdown (app) << terminationGracePeriodSeconds (pod spec)
    ```

    ([Link to Kubernetes pod termination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination))

6. **Sidecar Knowhow (Startup and Shutdown)**: Services using a sidecar for authentication, rate limiting, etc. should orchestrate their startup and shutdown. From Kubernetes perspective they are one entity. Problem is that the processes start unsynchronized, meaning that it is not defined/orchestrated when which container in the pod starts. Depending on when the processes get ready the pod throws errors on startup.
TODO: fill in

7. **(Bonus) Kubernetes response time critical applications**: A lesser known fact is that cpu limits do actually have performance impact even if the usage is not near the requested cpus! Fractions of cpu perform worse than whole cpus, but you will achieve the best performance with setting no limits at all! That may sound surprising but several experiments showed that removing the limits increased the 95 percentile of response times by about 30%! There is of course the risk of so called _noisy neighbors_ but you may be able enforce autoscaling everywhere (which mitigates noisy neighbors if the target utilization is well below 100%) or configure node groups that partition the cluster in several groups, e.g. one group for applications that have no limits and one group for all other applications. ([Link to references](https://medium.com/omio-engineering/cpu-limits-and-aggressive-throttling-in-kubernetes-c5b20bd8a718))

## Presentation [Slidev](https://github.com/slidevjs/slidev)

To start the slide show:

- `npm install`
- `npm run dev`
- visit [http://localhost:3030](http://localhost:3030)

Edit the [slides.md](./slides.md) to see the changes.

Learn more about Slidev on [documentations](https://sli.dev/).

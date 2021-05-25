# HPA Demo for old and new HPA spec

This project is a small demo regarding the behaviour of the HPA (horizontal pod autoscaler) for local execution.

## Documentation

### How does the test work conceptually?

We use an image from google that is able to generate load:

    gcr.io/kubernetes-e2e-test-images/resource-consumer:1.5

This image can be used to generate load as follows:

    curl --data "millicores=500&durationSec=600" http://192.168.64.7:8080/ConsumeCPU

The parameters `millicores` and `durationSec` can be adjusted accordingly. The IP has to be configured correctly, of course.

Using this image it is "very easy" to simulate load over defined time ranges - and even simulate increasing and decreasing loads (e.g. start base load of 500m for 10 minutes and after two minutes start a spike load of further 500m for 5 minutes). You can test different HPA configurations with this pod.

**Be aware** that you need a metrics server and it is advisable to increase the metrics-resolution to e.g. 15 seconds, see [patch-metrics.yaml](./patch-metrics.yaml). Using this you see the results faster.

### Application to Kubernetes

You can apply the pod `loadgen` to kubernetes using the [loadgen.yaml](./loadgen.yaml).

    kubectl apply -f loadgen.yaml

Four objects are created:

- Deployment with name `loadgen` that contains the resource-consumer container
- Horizontal Pod Autoscaler with name `loadgen` in version 1 with target utilization of 50 percent
- Service with name `loadgen`
- Ingress with name `loadgen`

We use here a traefik ingress that is default in k3s (layer 7 loadbalancer, for local execution we use [nip.io](https://nip.io) for dns resolution), but you can choose whatever you want. A standard (pre-1.18) HPA is configured and you can observe how it scales with different loads.

If you want to test a (post-1.18) HPA, you can drop the 'old' hpa using:

    kubectl delete hpa loadgen

and apply the new loadgen hpa using the [loadgen-newhpa.yaml](./loadgen-newhpa.yaml):

    kubectl apply -f loadgen-newhpa.yaml

This new HPA is configured to scale down 1 instance every 30 seconds (if the metrics of the last 60 seconds allow it). It is able to double its instances every 30 seconds (if the metrics of the last 60 seconds force this).

### Findings/Results

- Parameter `stabilizationWindowSeconds`: The number of seconds that are looked back in the metrics history for preventing flipping states
- Parameter `periodSeconds` in the policies: The interval in number of seconds that the autoscaler applies this policy. There can be multiple policies in the `scaleUp` or `scaleDown` behaviour.
- Parameter `selectPolicy` in the `scaleUp` or `scaleDown` behaviour can be set to `Min`, `Max` or `Disabled`. For details see [the official docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#scaling-policies). In a nutshell, if you have multiple policies for a behaviour the policy is used to select the min/max value.

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

## Appendix

### Links to further information

- [Kubernetes official docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Proposal for new HPA](https://github.com/kubernetes/enhancements/tree/master/keps/sig-autoscaling/853-configurable-hpa-scale-velocity#story-6-avoid-false-positive-signals-for-scaling-up)
- [Google Example](https://cloud.google.com/kubernetes-engine/docs/how-to/horizontal-pod-autoscaling#multiple-metrics)
- [Tencent Doc regarding HPA autoscaling/v2beta2](https://intl.cloud.tencent.com/document/product/457/39126#references) - beware, the comment regarding the `stabilizationWindowSeconds` is _wrong_!!!
- [Advanced HPA in Kubernetes Blog](https://www.kloia.com/blog/advanced-hpa-in-kubernetes)
- [Github: HPA Sourcecode Link](https://github.com/kubernetes/kubernetes/tree/master/pkg/controller/podautoscaler)

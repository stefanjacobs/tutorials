# Manual pod scaling - without loosing requests

Simple Kubernetes tutorials deal not with scenarios, where scale up or scale down actions occur without loosing requests. There are several things to observe:

- a service has to be ready before starting to serve requests
- a service has to finish its in-flight requests before shutting down
- Kubernetes is a highly distributed system with limited orchestration. This means, we have to ensure some things for ourselves.
- We need some testbed and load to verify our assumptions

## Challenges

## Scale Up

## Scale Down

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

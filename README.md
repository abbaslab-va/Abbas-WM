# Abbas-WM
Stores the working memory scripts for the Abbas lab. Each task is stored in its own folder with an associated set of training scripts.

Non-Match to Place (NMTP) scripts are for a spatial working memory task with a delay. The basic task structure is
>Mouse pokes sample port 
>Mouse holds delay port for 5 seconds
>Mouse is presented two lights in choice phase, one of which is the same as the sample light
>Mouse must choose the light it didn't visit in the sample to get the choice reward

These scripts are powered by the Bpod repository, an open source behavioral framework published and maintained by Sanworks, LLC. 
Audio is delivered using the Teensy Audio Module, controlled by a teensy 3.6 board and delivered through speakers mounted to the behavioral boxes.
THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Quick Start:
------------
	
	Run reconstructLayers.m with at least 4GB of RAM. 
	The pre-rendered light fields are in the data/ folder, for changing the current
	scene, edit and run data/generateLightField.m.  


More Details:
-------------

The software implements tomographic light field synthesis using layers of either light attenuators (e.g., inkjet-printed transparencies or LCDs) or polarization rotators (LCDs) as described in the following publications:

- Wetzstein, G., Lanman, D., Heidrich, W., Raskar, R. "Layered 3D: Tomographic Image Synthesis for Attenuation-based Light Field and High Dynamic Range Displays". ACM Trans. Graph. (Siggraph) 2011.

- Lanman, D., Wetzstein, G., Hirsch, M., Heidrich, W., Raskar, R. "Polarization Fields: Dynamic Light Field Display using Multi-Layer LCDs". ACM Trans. Graph. (Siggraph Asia) 2011. 

Physical display parameters can be adjusted in 'reconstructLayers.m' as can be switched between light attenuating and polarization rotating mode.



Questions or comments: send me an email gordonw@media.mit.edu



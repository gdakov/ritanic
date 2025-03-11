/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


//large core max dual display, works everywhere, no signal splitting the core
`define wport 12
//but really 9 cores, + 3 port insert/write coalescing

//iraloka lvl 2 gold silicon, 2x lvl 1 unused, 1/3rd utilisation:
//`define wport 144
//but cores are 108
//only possible in fully conductive box with hardly any plastic windows given inraloka uses gold radiator free energy devices
//10 way split for non usa like and 12 for usa like
//so for Europe / UK most of will reduce to 90 vector and ram capacity could be greater than advertized to allow for transparent reduction or it can be reduced by os or user.

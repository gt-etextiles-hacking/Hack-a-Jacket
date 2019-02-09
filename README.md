# Hack-a-Jacket

<iframe src="https://drive.google.com/file/d/1nTOyBVmwn_UDsFpa6DYz5XrVcCuCuKf4/preview" width="640" height="480"></iframe>

# Hacking the Levi’s Jacket: Exporting the Tag
## Project Proposal | CS 4605 | Mobile & Ubiquitous Computing
#### Rhea Chatterjee, Aayush Kumar, Kenzy Mina, Obinna Onyeije { rchatterjee32,  aayush.kumar, kenzy.mina,  oonyeije3 } @gatech.edu
##### Georgia Institute of Technology, Atlanta, GA, USA

## 1.  ABSTRACT

New user interfaces afford innovations in the user experience of computers—the interactive textile approach posed by Jacquard is another step in this evolution. Although it demonstrates new gestures via the Levi’s Jacquard Jacket collaboration, there is great potential for other applications and forms of user inputs. We plan to introduce new gestures to the Jacquard swatch and with export it to a satchel/backpack shoulder strap. We plan to use the pressure readings from each Jacquard thread with the existing 1-D touch localization data to create two dimensional gestures (ie:  [iPhone force-touch](https://www.patentlyapple.com/patently-apple/2017/10/apples-original-3d-touch-patents-surface-in-europe-this-week-with-over-500-patent-figures.html) ). Any additional gestures will only be considered successful if they are consistent and reliable with the IOS Jacquard Toolkit developed last semester. Thus, our goal is to successfully introduce at least one 2-D gesture, and ideally discovering other existing and/or potential new gestures. In addition, we aim to have at least one prototype of a jacquard swatch interwoven into a shoulder pad for a backpack or satchel.**Author Keywords**
Jacquard; e-textiles; wearables**ACM Classification Keywords**
H.5.m. Information interfaces and presentation (e.g., HCI):
Miscellaneous;
**2.  AIMS & OBJECTIVES **
We hope to introduce a new and intuitive gesture that not only adds to the Levi’s Jacket experience, but also naturally fits into user experience for the shoulder strap. To assess how “natural” this user interface will be, we plan to conduct user experiments and thereby determine the success of our work.
Beyond the scope of our defined project, we would like to help the other Hack the Levi’s Jacket team expand the toolkit to Android by providing user testing feedback if possible/helpful and thereby promoting a hacker culture around the jacquard swatches.

## 3.  BACKGROUND
The concept of smart fabric was introduced by Post and Orth of the MIT Media Lab. The authors created microcontroller circuits embedded into the fabric, soldering electronic components such as capacitors onto it [1]. This proposition of a seamless mesh of computing and textiles came two years before Weiser’s renowned Scientific American article, in which he spoke of literally “[technologies that] weave themselves into the fabric of everyday life and are indistinguishable from it.” While Weiser predicted a world of seamless, ubiquitous computing of tabs, pads, and boards, smart textiles were not something that was mentioned in his seminal work [2]. Building upon their initial idea, Post and Orth introduced the concept of e-broidery whereby embroidered fabrics were used to collect input to micro-controlled circuits. They also proposed the use of fabric that was in metallic and conductive, such as gold organza which is in itself not a new technology, having existed for centuries. One of the garments they created for their research was a musical denim jacket, with an embroidered keypad which allowed the user to create their own music through an embedded speaker [3]. The use of conductive thread in embroidery continued to be developed into fabric widgets, which mimicked the GUI widgets that we interact with on our screens day-to-day, such as rocker switches and joggers. This made the embroidered interfaces much more familiar to users, making mundane virtual actions such as scrolling and navigating menus tactile and physical [4, 5]. Concerns with this built-in interactivity included the washability of these garments and how that would affect the functionality of these interfaces [6]. Further challenges included scalability, as stitching and embroidery is expensive and time consuming, and the integration with electronics was not a natural fit for current industry processes [7]. One key delineation with the concept of e-broidery is that although it was one large step towards seamless interaction between clothing and computers, it was not quite close enough because of the conspicuousness of the embroidered widget. Interactivity had not yet completely disappeared into the fabric [7].
The solution to these problems came with the conception of Project Jacquard by Google, a new e-textile that uses a weaving technique as opposed to embroidery or stitching [7]. Poupyrev et. al of Google ATAP proposed the fabric, a two-dimensional topology of conductive yarns woven into materials of varying textures and colors, providing a natural feel to the user and fitting the needs of industrial processes and durability for maintaining functionality. These yarns consist of a conductive twisted core braided with two strands of silk to give structure, and then braided to protect the core and provide a normal fabric feel. Yarns are arranged in arrays and interfaced with an interposer attached to the fabric, which then interfaces with a sensing module which communicates with the processing module. Proposed applications included garments and interactive environments and IoT.
The smart denim jacket has returned in the form of Levi’s Jacquard jacket, which uses the Jacquard fabric in sleeve cuff. The cuff is able to recognize gestures such as brush in, brush out, and double tap. These gestures are used to interface with a smartphone via a flexible Bluetooth tag plugged into the cuff. This is the first commercialized e-textile garment on the market.
The jacket is the subject of this project. Our team has proposed augmenting the gestures already programmed into the tag to give it more functionality and exporting the tag and jacquard swatch to other garments, such as a bag shoulder strap or a wristwatch band. This is because we believe the intended commuter-style of the jacket is not practical for example, for a biking commuter in the summertime. Our team intends to build on the work of a previous MUC team who had developed an API for iOS for the tag and used it in a [ developer’s toolkit](https://github.com/calebrudnicki/JacquardToolkit/tree/master/JacquardToolkitExample)  they created using Cocoapods.

## 4.  CHALLENGES & ALIGNMENT TO CLASS
**Proprietary Code**

The most obvious difficulty involved in exporting the tag involves determining the extent to which the pre-built code by Google offers functionality to Jacquard users. This cannot be done by looking at the code directly, as the software is pre-compiled and not in a readable format. We must instead determine the possible range of the jacket’s function by measuring input and output wireless signals through third-party software, and then compile these into the API generated by a previous project group.The members of our project group are generally unfamiliar with Swift, the proprietary development language of Apple devices. As the API created by the previous project group was written for iOS, we will need to familiarize ourselves with this programming language, which will involve working with both iOS and macOS devices.

**Working with textile elements**

The Jacquard technology can be classified as “ubiquitous” technology because the function of the gesture-recognition technology has been integrated seamlessly with the function of the jacket. However, this presents a problem to developers who wish to export this function to other wearables. The section of the technology which has been made part of the cloth is extremely malleable and fragile, and it may be difficult to extract the relevant components from the fabric. Our group may need to obtain excess jackets or samples thereof from Google or other companies which specialize in “smart fabric.”

**Relevance to Ubicomp**

The Jacquard technology is a particularly well-designed example of sensors and wireless technology blended together so as to be nearly indistinguishable from the clothing it has been sewn to. As such, it is an excellent example of ubiquitous computing. Our work on the jacket will demonstrate the benefits of ubicomp and its execution, as well as the inherent difficulty in making the technology accessible to casual users.

## 5.  OUTCOMES & DELIVERABLES
Through this project, our team hopes to gain experience in (1) e-textiles, (2) iOS app development, (3) machine-learning through the development of new gestures, and (4) prototyping and sewing.
As deliverables for this project, our team intends to successfully isolate the jacquard swatch from the cuff of the jacket, produce a functional gesture for the jacquard cuff and a bag shoulder strap integrating jacquard and the bluetooth tag, and conduct a user study of the shoulder strap. These technical deliverables are in addition to deliverables for the class, including revised version of this project proposal, a video demonstration, a final presentation, and a final report of our accomplishments.

## 6.  PROJECT PLAN & TIMELINE

**Onboarding**

We plan to begin with an onboarding process such that all members of the team will become familiar with iOS development using Swift in order to explore the current iOS Jacquard Toolkit.
**Gestures **
Before exporting the technology, we plan to explore the current gestures supported by the thread. After identifying individual thread location and pressure readings, we will be able to hypothesize new possible 2-dimensional gestures for data collection. Using machine learning techniques, we will examine the noise created by 2D gestures via pressure and subsequently train the data to recognize gestures. We will simultaneously work on figuring out what the unidentified 0x04, 0x05, and 0x06 gestures may be. The next step will be to test and augment the iOS Jacquard toolkit with the newly created and/or identified gestures.
**Prototyping **
After exploring and adapting the Jacquard swatch, we will attach it to a backpack or shoulder strap. This will involve learning to use a sewing machine and devising the most useful and efficient way to export the tag. After creating the prototype, we plan to conduct user tests and apply feedback.

**Timeline**
Please see the appendix for our  updated timeline of tasks, assignments, and key milestones as well as the Gantt chart.

## REFERENCES
1. Post, E. R. and Orth, M. *Smart fabric, or” wearable clothing”*. IEEE, City, 1997.
2.Weiser, M. The computer for the 21st century. *Mobile Computing and Communications Review*, 3, 3 (1999), 3-11.
3.Post, E. R., Orth, M., Russo, P. R. and Gershenfeld, N. E-broidery: Design and fabrication of textile-based computing. *IBM Systems journal*, 39, 3.4 (2000), 840-860.
4. Gilliland, S., Komor, N., Starner, T. and Zeagler, C. *The Textile Interface Swatchbook: Creating graphical user interface-like widgets with conductive embroidery*. IEEE, City, 2010.
5.Zeagler, C., Gilliland, S., Profita, H. and Starner, T. *Textile interfaces: Embroidered jog-wheel, beaded tilt sensor, twisted pair ribbon, and sound sequins*. IEEE, City, 2012.
6.Zeagler, C., Gilliland, S., Audy, S. and Starner, T. *Can I wash it?: the effect of washing conductive materials used in making textile based wearable electronic interfaces*. ACM, City, 2013.
7.Poupyrev, I., Gong, N.-W., Fukuhara, S., Karagozler, M. E., Schwesig, C. and Robinson, K. E. Project Jacquard (2016), 4216-4227.

## APPENDIX

**A.1 Timeline**

Tasks Added:
- Decode Jacquard Tag Protocol
- Test & Analyze Newly Augmented iOS Jacquard Toolkit
- Design & Build Prototype of the Embedded Controller
- Design & Sew Swatching Using Conductive Thread
- Combine Controller, Swatch, & Tag
- Test Prototype

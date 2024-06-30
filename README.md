# Icarus Inc. Autocrafter

This is the source code for the Icarus Inc. Autocrafter, found on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3278621686)

## User Manual
### Installation

1. Place the Blueprint
2. Connect the Blueprint via DataCables to your Containers, Crafters, and FluidTanks
3. Name the Connected Components:
  - Use the Router (DataPorts) or manually use 'V' to name the connected components
  - Naming conventions (# is a number from 1, _ is the tank content (e.g., H2, H2O, O2)):
    * Containers: "Container #"
    * Crafters: "Crafter #"
    * FluidTanks: "_ Tank #"
4. Double Check:
  - Ensure all connected Crafters can pull from all connected Tanks and Containers
  - Ensure all connected Crafters can push into a connected Container they can all pull from
  - Ensure all connected FluidTanks for the same fluid are the same size
5. Configure the Code to your setup (see Customization below)

### Interface
- The Interface has three screens: "Crafting", "Queue", and "Storage"
- Screen Selector (three buttons at the top): Switches between screens
- Scroll Wheel (three buttons on the right): Scrolls up / down (the 0 button scrolls to the top)

1. Crafting Screen: This screen functions similarly to the standard crafter
  - Quantity Selector (left of the "Scroll Wheel"): Adds or subtracts (+/-) either 1000 (k), 100 (h), 10 (d), or 1 from the currently selected quantity (to a minimum of 1)
  - Craft Button (bottom of the screen):
    * Shows the selectet quantity
    * Starts crafting the selected item in the selectet quantity

2. Queue Screen: This screen lists all currently queued items and their quantities with progress bars.

3. Storage Screen: This screen lists all raw resources and three numbers (in kg)
  - Left most number: Amount needed to craft the selected craft
  - Middle number: Amount needed for the queue
  - Right most number: Amount that will remain in the inventory after the queue is completed

### Customization
1. Remove the Back Panel (sloped blocks on the back)
2. Hit the Code Button
3. Locate the Settings: All settings are found between the two ;---Settings--- comments at the top of the code
4. Specify Components:
  - Use the ..._count variables to specify how many Containers, Crafters, and FluidTanks you have
  - Use the ..._volume variables to specify the tank sizes (in m³)
5. Cosmetic Changes: The rest of the variables are for cosmetic changes (note: some values result in graphics bugs)

## Sales Pitch

We are thrilled to introduce you to a groundbreaking innovation from Icarus Inc. – The Auto Crafter.

The Auto Crafter is designed to revolutionize the way you approach crafting and manufacturing. It automates and streamlines the crafting process, making it faster, more efficient, and more intuitive than ever before.

One of the standout features of the Auto Crafter is its Multi Crafter Support. This feature drastically improves crafting speed by allowing multiple crafting processes to run simultaneously.

Our Auto Crafter also comes equipped with advanced Inventory Monitoring. This intelligent system ensures you never start crafting something for which you lack resources. It keeps a real-time check on your inventory, preventing costly mistakes and resource wastage.

To top it all off, the Auto Crafter features a fully Customizable Interface. You can tailor the dashboard to fit your specific needs and preferences, making it easier and more enjoyable to use.

We believe the Auto Crafter will be a game-changer in your crafting and manufacturing processes.

We highly recommended reading the manual before using the Auto Crafter.

Icarus Inc. – *Reach for the Stars*

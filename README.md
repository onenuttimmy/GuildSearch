 GuildSearch (WoW 1.12.1)

**GuildSearch** is a lightweight, standalone addon for World of Warcraft 1.12.1 (Vanilla) that replaces the clumsy default guild interface with a fast, searchable, and sortable roster list.

It is designed to be **simple**, **crash-free**, and **feature-rich**, allowing Guild Masters and members to find exactly who they are looking for in seconds.

## 🌟 Features

* **Real-Time Search:** Filter your guild list instantly by **Name**, **Class**, **Level**, or **Zone**.
* **Smart Sorting:** Click column headers (Lvl, Class, Name, Zone) to sort Ascending or Descending.
    * *Default Sort:* Level (Low to High).
* **Quick Actions:**
    * **Left-Click:** Whisper the player.
    * **Shift + Left-Click:** Perform a `/who` lookup on the player.
    * **Right-Click:** Opens a Context Menu with options:
        * Whisper
        * Invite to Group
        * Add Friend
        * **GM Tools:** Promote, Demote, Kick (Visible only if you have permission).
* **Offline Support:** automatically loads offline members so you can search the full roster.
* **Crash Protection:** "Safe Search" prevents the addon from breaking if you type special characters (like `[` or `(`).

## 📂 Installation

Since this is a custom-made addon, you will need to create the files manually or paste the code into the correct location.

1.  Navigate to your World of Warcraft installation folder.
2.  Go to `Interface` -> `AddOns`.
3.  Create a new folder named `GuildSearch`.
4.  Inside that folder, ensure you have these two files:
    * `GuildSearch.toc`
    * `GuildSearch.lua`

*(Make sure the code inside `GuildSearch.lua` is the latest version provided).*

## 🎮 Usage

### Opening the Window
Type either of the following commands in the chat window:
* `/gs`
* `/guildsearch`

### Searching
* Type in the search box at the top.
* **Examples:**
    * Type `"Mage"` to see all Mages.
    * Type `"Blackrock"` to see everyone in Blackrock Mountain.
    * Type `"60"` to see all Level 60s.

### Interactions
| Action | Result |
| :--- | :--- |
| **Left Click** | Auto-fills a whisper (`/w Name`) to the player. |
| **Shift + Click** | Performs a `/who Name` search (useful to check exact location/guild). |
| **Right Click** | Opens the **Interaction Menu** (Invite, Friend, Promote, Kick, etc). |
| **Reset Button** | Clears the search text and resets sorting to Level (Low -> High). |

## 🛠 Troubleshooting

* **"Attempt to index nil value" error:**
    * This usually means you are running an old version of the code. Ensure you have the latest version (v2.7) installed.
* **Nothing happens when I type `/gs`:**
    * Make sure the folder is named exactly `GuildSearch` and the `.toc` file is named `GuildSearch.toc`.
    * Ensure the `.toc` file references `GuildSearch.lua` correctly.
    * Restart your WoW client completely (logging out is sometimes not enough for new files).
 
    * 

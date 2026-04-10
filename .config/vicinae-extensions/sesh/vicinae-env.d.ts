/// <reference types="@vicinae/api">

/*
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 */

type ExtensionPreferences = {

}

declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Command: Connect to Session */
	export type CmdConnect = ExtensionPreferences & {
		/** Open with (required) - Open with */
		"openWithApp"?: string;

		/** Environment Path - Colon-separated PATH (Unix-style), e.g /usr/local/bin:/usr/bin */
		"environmentPath"?: string;
	}
}

declare namespace Arguments {
  /** Command: Connect to Session */
	export type CmdConnect = {

	}
}
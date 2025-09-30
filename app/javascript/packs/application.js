// app/javascript/packs/application.js

// Rails UJS, Turbolinks, ActiveStorage (classic Rails defaults)
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// Start Rails stuff
Rails.start()
Turbolinks.start()
ActiveStorage.start()

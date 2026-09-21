# Dark mode

Status: approved (2026-09-21)

## Goal
Users can switch between light and dark themes; the choice is saved in a cookie and applied on the server so there's no flash of the wrong theme.

## End-to-end check
Playwright: toggle to dark, reload, the <html> element still has data-theme="dark" before hydration.

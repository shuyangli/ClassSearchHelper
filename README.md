ClassSearchHelper
=================

An Objective-C library for Class Search. May be ported to other languages soon.

## To-Do's
- [ ] Better design for the scheduler constraint system
  - [x] "Required constraint": "This schedule is rejected if it doesn't match this criteria"
    - Easy: if a schedule matches any of the required constraints, it's ruled out
    - We can have a set of required scheduler constraints
  - [ ] "Ranking constraint": "Of all accepted schedules, this determines their order"
    - Hard: what about multiple ranking constraints?
      - We want them to be customizable
      - We want to be able to easily change their priority
      - Do we let the developer write an enormous block that considers all possibilities?
        - More work for developer
        - Harder to ship pre-defined constraints 
      - Do we let developers write multiple smaller-scale blocks, and then consider all of them?
        - How to implement the priorities?
  - [ ] More course/schedule attributes to work with when setting up constraints
    - "I want to walk as little as possible"
    - "I want to have the highest professor rankings"
- [ ] Consider prerequisites and corequisites when scheduling
- [ ] Pretty-print the schedule!
  - Also figure out how to do a GUI
- [ ] Tracking for preferred courses, so we know which are "popular"

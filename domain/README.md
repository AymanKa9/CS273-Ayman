## Mission Statement
To store player ID, tournament structure, match outcomes, handicap and Fargo-Rating for competitive pool events.


## Mission Objectives
- Maintain accurate player identity and contact records.
- Track player Fargo Ratings and game total indicators.
- Manage tournament parameters including formats, and game types.
- Record individual match schedules, table assignments, and final scores.
- Store handicap lookup thresholds based on rating differentials between opponents.
- Log pre-match and post-match rating updates to preserve historical rating accuracy.


## Domain Description
This database serves pool tournament directors, league operators, and competitive cuesports players who require transparent match tracking and fair play mechanisms. Tournament operators use the platform to orchestrate event structures, establish balanced match race goals based on player skill levels, and record official results. Players use the system to track their historical win rates across various disciplines, monitor their Fargo Rating growth, and verify handicap assignments prior to competing.
A relational database model is ideal for this domain because of the structural fields between entities. Calculating accurate handicap races requires joining two distinct player rating records with static lookup tables based on rating gaps.

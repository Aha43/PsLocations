## wip on making end to end test list

- [ ] 1 create test area directory TestArea
- [ ] 2 create in test area a locations directory named TestLocations, set $env:LocHome to point to it
- [ ] 3 make a directory under TestAres called Loc1 and make it the current dir
- [ ] 4 **create location: *loc add . 'Location 1'***
- [ ] 5 **loc l**
  - [ ] 5.1 One location should be listed
    - [ ] 5.1.1 Position should be '0'
    - [ ] 5.1.2 Name should be 'Loc1'
    - [ ] 5.1.3 Path should end with 'TestArea/Loc1'
    - [ ] 5.1.4 Description should be 'Location 1'
    - [ ] 5.1.5 Only one machine should be listed 
    - [ ] 5.1.6 The machine listed should be the one test are running
- [ ] 6 cd .. (move to TestArea)
- [ ] 7 **loc '0'**
  - [ ] 7.1 Working directory should now be 'Loc1'
- [ ] 8 cd .. (move to TestArea)
- [ ] 9 **loc 'Loc1'**
  - [ ] 9.1 Working directory should now be 'Loc1'
- [ ] 10 **loc rename . 'Loc1-renamed'**
- [ ] 11 **loc list**
  - [ ] 11.1 => Same as 5.1 but 5.1.2 shouls assert 'Loc1-renamed'
- [ ] 12 cd .. (move to test area)
- [ ] 13 **loc 'Loc1-renamed'**
  - [ ] 13.1 Working directory should now be 'Loc1'
- [ ] 14 **loc edit . 'Location 1 Edit 1'**
- [ ] 15 **loc l**
  - [ ] 15.1 => Same as 11.1 but 5.1.4 should assert 'Location 1 Edit 1'
- [ ] 16 **loc edit 'Loc1-renamed' 'Location 1 Edit 2**
- [ ] 17 **loc l**
  - [ ] 17.1 => Same as 15.1 but 5.1.4 should assert 'Location 1 Edit 2'
- [ ] 18 **loc note . 'Loc 1 Note 1'**
- [ ] 19 **loc notes .**
  - [ ] 19.1 Should list one note
  - [ ] 19.2 Notes content should be 'Loc 1 Note 1'
- [ ] 20 **loc note 'Loc1-renamed' 'Loc 1 Note 2**
  - [ ] 20.1 ...
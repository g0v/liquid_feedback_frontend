function setCategoryHeadings() {
  var approvalCount = 0;
  var disapprovalCount = 0;
  var sections = document.getElementById("voting").childNodes;
  for (var i=0; i<sections.length; i++) {
    var section = sections[i];
    if (section.className == "approval")       approvalCount++;
    if (section.className == "disapproval") disapprovalCount++;
  }
  var approvalIndex = 0;
  var disapprovalIndex = 0;
  for (var i=0; i<sections.length; i++) {
    var section = sections[i];
    if (
      section.className == "approval" ||
      section.className == "abstention" ||
      section.className == "disapproval"
    ) {
      var setHeading = function(heading) {
        var headingNodes = section.childNodes;
        for (var j=0; j<headingNodes.length; j++) {
          var headingNode = headingNodes[j];
          if (headingNode.className == "cathead") {
            headingNode.textContent = heading;
          }
        }
      }
      var count = 0;
      var entries = section.childNodes;
      for (var j=0; j<entries.length; j++) {
        var entry = entries[j];
        if (entry.className == "movable") count++;
      }
      if (section.className == "approval") {
        if (approvalCount > 1) {
          if (approvalIndex == 0) {
            if (count == 1) setHeading("Zustimmung (Erstwunsch)");
            else setHeading("Zustimmung (Erstwünsche)");
          } else if (approvalIndex == 1) {
            if (count == 1) setHeading("Zustimmung (Zweitwunsch)");
            else setHeading("Zustimmung (Zweitwünsche)");
          } else if (approvalIndex == 2) {
            if (count == 1) setHeading("Zustimmung (Drittwunsch)");
            else setHeading("Zustimmung (Drittwünsche)");
          } else {
            if (count == 1) setHeading("Zustimmung (" + (approvalIndex+1) + ".-Wunsch)");
            else setHeading("Zustimmung (" + (approvalIndex+1) + ".-Wünsche)");
          }
        } else {
          setHeading("Zustimmung");
        }
        approvalIndex++;
      } else if (section.className == "abstention") {
        setHeading("Enthaltung");
      } else if (section.className == "disapproval") {
        if (disapprovalCount > disapprovalIndex + 2) {
          setHeading("Ablehnung (jedoch Bevorzugung gegenüber unteren Ablehnungsblöcken)")
        } else if (disapprovalCount == 2 && disapprovalIndex == 0) {
          setHeading("Ablehnung (jedoch Bevorzugung gegenüber unterem Ablehnungsblock)")
        } else if (disapprovalIndex == disapprovalCount - 2) {
          setHeading("Ablehnung (jedoch Bevorzugung gegenüber letztem Ablehnungsblock)")
        } else {
          setHeading("Ablehnung");
        }
        disapprovalIndex++;
      }
    }
  }
}
function elementDropped(element, dropX, dropY) {
  var oldParent = element.parentNode;
  var centerY = dropY + element.clientHeight / 2
  var approvalCount = 0;
  var disapprovalCount = 0;
  var mainDiv = document.getElementById("voting");
  var sections = mainDiv.childNodes;
  for (var i=0; i<sections.length; i++) {
    var section = sections[i];
    if (section.className == "approval")       approvalCount++;
    if (section.className == "disapproval") disapprovalCount++;
  }
  for (var i=0; i<sections.length; i++) {
    var section = sections[i];
    if (
      section.className == "approval" ||
      section.className == "abstention" ||
      section.className == "disapproval"
    ) {
      if (
        centerY >= section.offsetTop &&
        centerY <  section.offsetTop + section.clientHeight
      ) {
        var entries = section.childNodes;
        for (var j=0; j<entries.length; j++) {
          var entry = entries[j];
          if (entry.className == "movable") {
            if (centerY < entry.offsetTop + entry.clientHeight / 2) {
              if (element != entry) {
                oldParent.removeChild(element);
                section.insertBefore(element, entry);
              }
              break;
            }
          }
        }
        if (j == entries.length) {
          oldParent.removeChild(element);
          section.appendChild(element);
        }
        break;
      }
    }
  }
  if (i == sections.length) {
    var newSection = document.createElement("div");
    var cathead = document.createElement("div");
    cathead.setAttribute("class", "cathead");
    newSection.appendChild(cathead);
    for (var i=0; i<sections.length; i++) {
      var section = sections[i];
      if (
        section.className == "approval" ||
        section.className == "abstention" ||
        section.className == "disapproval"
      ) {
        if (centerY < section.offsetTop + section.clientHeight / 2) {
          if (section.className == "disapproval") {
            newSection.setAttribute("class", "disapproval");
            disapprovalCount++;
          } else {
            newSection.setAttribute("class", "approval");
            approvalCount++;
          }
          mainDiv.insertBefore(newSection, section);
          break;
        }
      }
    }
    if (i == sections.length) {
      newSection.setAttribute("class", "disapproval");
      disapprovalCount++;
      mainDiv.appendChild(newSection);
    }
    oldParent.removeChild(element);
    newSection.appendChild(element);
  }
  sections = mainDiv.childNodes;
  for (i=0; i<sections.length; i++) {
    var section = sections[i];
    if (
      (section.className == "approval"    &&    approvalCount > 1) ||
      (section.className == "disapproval" && disapprovalCount > 1)
    ) {
      var entries = section.childNodes;
      for (var j=0; j<entries.length; j++) {
        var entry = entries[j];
        if (entry.className == "movable") break;
      }
      if (j == entries.length) {
        section.parentNode.removeChild(section);
      }
    }
  }
  setCategoryHeadings();
}
window.addEventListener("load", function(event) {
  setCategoryHeadings();
  var mainDiv = document.getElementById("voting");
  var form = document.getElementById("voting_form");
  var elements = document.getElementsByTagName("input");
  for (var i=0; i<elements.length; i++) {
    var element = elements[i];
    if (element.className == "voting_done") {
      element.addEventListener("click", function(event) {
        var scoringString = "";
        var approvalCount = 0;
        var disapprovalCount = 0;
        var sections = mainDiv.childNodes;
        for (var j=0; j<sections.length; j++) {
          var section = sections[j];
          if (section.className == "approval")       approvalCount++;
          if (section.className == "disapproval") disapprovalCount++;
        }
        var approvalIndex = 0;
        var disapprovalIndex = 0;
        for (var j=0; j<sections.length; j++) {
          var section = sections[j];
          if (
            section.className == "approval"    ||
            section.className == "abstention"  ||
            section.className == "disapproval"
          ) {
            var score;
            if (section.className == "approval") {
              score = approvalCount - approvalIndex;
              approvalIndex++;
            } else if (section.className == "abstention") {
              score = 0;
            } else if (section.className == "disapproval") {
              score = -1 - disapprovalIndex;
              disapprovalIndex++;
            }
            var entries = section.childNodes;
            for (var k=0; k<entries.length; k++) {
              var entry = entries[k];
              if (entry.className == "movable") {
                var id = entry.id.match(/[0-9]+/);
                var field = document.createElement("input");
                scoringString += id + ":" + score + ";";
              }
            }
          }
        }
        var fields = form.childNodes;
        for (var j=0; j<fields.length; j++) {
          var field = fields[j];
          if (field.name == "scoring") {
            field.setAttribute("value", scoringString);
            form.submit();
            return;
          }
        }
        alert('Hidden input field named "scoring" not found.');
      }, false);
    }
  }
}, false);

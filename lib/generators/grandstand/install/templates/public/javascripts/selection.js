/*  
*  Selection.js
*  Copyright (c) 2010 Flip Sasser, All Rights Reserved
*  Use to manipulate a text selection object using jQuery. Fun!
*
*/

require('string');

$.extend($.expr[':'], {
  block: function(a) {
    return $(a).css('display') === 'block';
  },
  textnode: function(a) {
    return a.nodeType == 3;
  }
});

jQuery.fn.selection = function(rootSelector) {
  return new Selection(this[0], rootSelector);
};

// The selection class will provide some basic range finding methods, such as:
// * Find text before and after the selection, inside of current block
// * Move the caret to a block if it's in a Textnode directly under body
// The selection class can be used to move after() to a new adjacent
// block without much overhead or trouble. It can also be used to wrap,
// unwrap, and detect wrapping tags in, HTML content. Example:
// 
// var selection = $(window).selection();
// var before = selection.before();
// var after = selection.after();
// // Splits the `before` and `after` into
// // two new blocks; the default block type is
// // paragraph but that can be changed:
// var newParagraph = selection.split('p');
// selection.wrap('strong');
// selection.unwrap('strong');
// selection.wrappedIn('strong'); //=> true if the selection is inside <strong>
// selection.insert('<img alt="Image!" src="/images/foo.gif" />');

var Selection = function(element, rootSelector) {
  this.window = element;
  this.document = element.document;
  this.rootSelector = rootSelector || 'body';
  this.root = $(this.document).find(this.rootSelector + ':first');
};

Selection.prototype = {
  // `after` and `before` return the strings before and after the current selection,
  // inside of the current block (or an automatically-created paragraph block).
  after: function() {
    return this.afterRange().toString();
  },
  afterAll: function() {
    var range = this.range();
    var afterAllRange = this.document.createRange();
    afterAllRange.selectNodeContents(this.root[0]);
    afterAllRange.setStart(range.endContainer, range.endOffset);
    return afterAllRange.cloneContents();
  },
  before: function() {
    return this.beforeRange().toString();
  },
  beforeAll: function() {
    var range = this.range();
    var beforeAllRange = this.document.createRange();
    beforeAllRange.setStart(this.root[0], 0);
    beforeAllRange.setEnd(range.startContainer, range.startOffset);
    return beforeAllRange.cloneContents();
  },
  afterRange: function() {
    return this._data('afterRange', function() {
      var endNode = this.endNode();

      var afterRange = this.document.createRange();
      afterRange.setStart(endNode[0], this.data['endOffset']);
      afterRange.setEnd(endNode[0], (endNode[0].wholeText || endNode.html()).length);
      return afterRange;
    });
  },
  beforeRange: function() {
    return this._data('beforeRange', function() {
      var startNode = this.startNode();

      var beforeRange = this.document.createRange();
      beforeRange.setStart(startNode[0], 0);
      beforeRange.setEnd(startNode[0], this.data['startOffset']);

      return beforeRange;
    });
  },
  endNode: function() {
    return this._data('endNode', function() {
      var beforeRange = this.document.createRange();
      beforeRange.setStart(this.selection.anchorNode, this.selection.anchorOffset);
      beforeRange.collapse(true);

      var afterRange = this.document.createRange();
      afterRange.setStart(this.selection.focusNode, this.selection.focusOffset);
      afterRange.collapse(true);

      var ltr = beforeRange.compareBoundaryPoints(beforeRange.START_TO_END, afterRange) < 0;

      var endNode = $(ltr ? this.selection.focusNode : this.selection.anchorNode);
      this.data['startNode'] = $(ltr ? this.selection.anchorNode : this.selection.focusNode);
      this.data['startOffset'] = ltr ? this.selection.anchorOffset : this.selection.focusOffset;
      this.data['endOffset'] = ltr ? this.selection.focusOffset : this.selection.anchorOffset;

      return endNode;

    });
  },
  endBlock: function() {
    return this._data('endBlock', function() {
      var endNode = this.endNode();
      var endBlock = $(endNode.parents(':block:not(body, html, ' + this.rootSelector + '):first')[0] || endNode);
      if (endBlock.length > 0) {
        endBlock[0].normalize();
      }
      return endBlock;
    });
  },
  // Inserts some content into the selection. Really, it just replaces the
  // current selection with the content. Coolness.
  insert: function(content) {
    this.replace(content);
  },
  normalize: function() {
    if (this.startBlock().length > 0) {
      this.startBlock()[0].normalize();
    }
    if (this.endBlock().length > 0) {
      this.endBlock()[0].normalize();
    }
  },
  // Returns the before or after range of the current selection, scoped to the
  // containing block. If no containing block is found, it automatically
  // creates one and set the range inside of it.
  range: function(name) {
    return this._data('range', function() {
      var range;
      if (this.selection.getRangeAt) {
        range = this.selection.getRangeAt(0);
      } else if (this.document.selection) {
        range = this.document.createRange();
        range.setStart(this.selection.anchorNode, this.selection.anchorOffset);
        range.setEnd(this.selection.focusNode, this.selection.focusOffset);
      }
      return range;
    });
  },
  // Replaces the selection with the passed-in content. Primarily used internally
  // for `insert` and `wrap`.
  replace: function(content) {
    this.range().deleteContents();
    var startNode = this.startNode();
    startNode.append(content);
    this.select(startNode);
  },
  // Sets the caret position inside the first element that matches the selector.
  // You can also pass in an element and an offset if you're feeling extra-aggressive,
  // but be forewarned: the element MUST appear inside the `root` element of the
  // selection, or you can go to hell, sir.
  select: function(selector, offset) {
    this.root.focus();
    var element;
    if (typeof(selector) == 'object') {
      element = $(selector);
    } else {
      if (!selector.match(':')) {
        selector = selector + ':first';
      }
      element = this.root.find(selector);
    }
    if (!offset) {
      offset = 0;
    }
    element = element[0];
    if (element) {
      if (!this.selection) {
        this.selection = this.window.getSelection ? this.window.getSelection() : this.document.selection;
      }
      var range = this.document.createRange();
      if (offset > 0) {
        range.setStart(element, offset);
        range.setEnd(element, offset);
      } else {
        range.selectNodeContents(element);
        range.collapse(true);
      }
      this.selection.removeAllRanges();
      this.selection.addRange(range);
    } else {
      this.root.focus();
    }
  },
  selectAll: function() {
    if (!this.selection) {
      this.selection = this.window.getSelection ? this.window.getSelection() : this.document.selection;
    }
    var range = this.document.createRange();
    range.selectNodeContents(this.root[0]);
    this.selection.removeAllRanges();
    this.selection.addRange(range);
  },
  split: function(tagname) {
    // Default to a new paragraph
    if (!tagname) {
      tagname = 'p';
    }
    tagname = tagname.toLowerCase();
    // Build whatever comes after the current node, cutting the contents out
    var afterNode = $('<' + tagname + '></' + tagname + '>');
    var after = this.afterRange();
    afterNode.html(after.cloneContents());
    afterNode.append('<br />');
    // Add the new node after the current block - and then, and this is important,
    // SELECT the top of that block
    var endBlock = this.endBlock();
    endBlock.after(afterNode);
    var startBlock = this.startBlock();
    if (startBlock == endBlock && startBlock.text() == '') {
      afterNode = $('<br />');
      startBlock.append(afterNode);
    }
    this.select(afterNode);
    this.range().deleteContents();
    after.deleteContents();
    startBlock[0].normalize();
    endBlock[0].normalize();
  },
  startBlock: function() {
    return this._data('startBlock', function() {
      var startNode = this.startNode();
      return startNode.parents(':block:not(body, html):first') || startNode;
    });
  },
  startNode: function() {
    return this._data('startNode', function() {
      var beforeRange = this.document.createRange();
      beforeRange.setStart(this.selection.anchorNode, this.selection.anchorOffset);
      beforeRange.collapse(true);

      var afterRange = this.document.createRange();
      afterRange.setStart(this.selection.focusNode, this.selection.focusOffset);
      afterRange.collapse(true);

      var ltr = beforeRange.compareBoundaryPoints(beforeRange.START_TO_END, afterRange) < 0;
      var startNode = $(ltr ? this.selection.anchorNode : this.selection.focusNode);
      this.data['startOffset'] = ltr ? this.selection.anchorOffset : this.selection.focusOffset;
      this.data['endNode'] = $(ltr ? this.selection.focusNode : this.selection.anchorNode);
      this.data['endOffset'] = ltr ? this.selection.focusOffset : this.selection.anchorOffset;

      return startNode;
    });
  },
  unwrap: function(tagname) {
    var tags = this.wrappedIn(tagname);
    if (tags) {
      var text = this.range().extractContents();
      tags.after(text);
      if (tags.text() == '') {
        tags.remove();
      }
    }
  },
  wrap: function(tagname) {
    // Nice, clean-looking HTML.
    tagname = tagname.toLowerCase();
    var wrapper = this.document.createElement(tagname);
    this.range().surroundContents(wrapper);
  },
  // Returns a boolean for whether or not the selection (or caret position)
  // is inside of a certain tag. Useful for activating / deactivating button
  // items as the user navigates.
  wrappedIn: function(selector) {
    var startNode = this.startNode();
    if (startNode.is(selector)) {
      return startNode;
    } else {
      var parents = startNode.parents(selector);
      if (parents.length === 0) {
        return false;
      } else {
        return parents;
      }
    }
  },
  _data: function(name, block) {
    if (!this.data) {
      this.data = {};
    }
    if (!this.data[name]) {
      this.selection = this.window.getSelection ? this.window.getSelection() : this.document.selection;
      this.data[name] = block.call(this);
    }
    return this.data[name];
  }
};

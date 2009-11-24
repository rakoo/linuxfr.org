var Chat = {
    /* FIXME do not share these variables */
    errorSleepTime: 500,
    cursor: null,
    inbox: null,
    chan: null,

    create: function(inbox, chan) {
        Chat.inbox = inbox;
        Chat.chan = chan;
        Chat.poll();
    },

    poll: function() {
        var args = {};
        if (Chat.cursor) args.cursor = Chat.cursor;
        $.ajax({
            url: "/chat/chan/" + Chat.chan,
            type: "POST",
            dataType: "text",
            data: $.param(args),
            success: Chat.onSuccess,
            error: Chat.onError
        });
    },

    onSuccess: function(response) {
        try {
            Chat.newMessages(eval("(" + response + ")"));
            Chat.errorSleepTime = 500;
            window.setTimeout(Chat.poll, 0);
        } catch (e) {
            Chat.onError();
        }
    },

    onError: function(response) {
        Chat.errorSleepTime *= 2;
        window.setTimeout(Chat.poll, Chat.errorSleepTime);
    },

    /* Dispatch messages to their callbacks */
    newMessages: function(response) {
        if (!response.messages) return;
        var messages = response.messages;
        var method, message;
        Chat.cursor = messages[messages.length - 1].id;
        for (var i = 0, message; i < messages.length; i++) {
            message = messages[i];
            method  = 'on_' + message['type'];
            Chat[method](message);
        }
    },

    /* Callback for a new message on the board */
    on_board: function(message) {
        var existing = $("#board-" + message.id);
        if (existing.length > 0) return;
        Chat.inbox.prepend(message.msg);
    }
};

$(".board").each(function() {
    var board = $(this);
    Chat.create(board.find('.inbox'), board.attr('data-chat'));
});

/* Post a message in ajax */
$('form.chat').submit(function() {
    var form = $(this);
    $.post(form.attr('action'), form.serialize(), function (response) {
        form.find("input[type=text]").val("").select();
    });
    return false;
});

/* Ready to moule */
$("#container form.chat input[type=text]").select();


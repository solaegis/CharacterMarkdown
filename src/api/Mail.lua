-- CharacterMarkdown - API Layer - Mail
-- Abstraction for mail system

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.mail = {}

local api = CM.api.mail

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumMail()
    return CM.SafeCall(GetNumMailItems) or 0
end

function api.GetMailInfo(mailId)
    if not mailId then
        return nil
    end

    local sender = CM.SafeCall(GetMailSender, mailId)
    local subject = CM.SafeCall(GetMailSubject, mailId)
    local readStatus = CM.SafeCall(IsMailRead, mailId)
    local attachmentStatus = CM.SafeCall(HasMailAttachments, mailId)
    local attachmentCount = 0

    if attachmentStatus then
        attachmentCount = CM.SafeCall(GetMailAttachmentCount, mailId) or 0
    end

    return {
        id = mailId,
        sender = sender or "Unknown",
        subject = subject or "",
        isRead = readStatus or false,
        hasAttachments = attachmentStatus or false,
        attachmentCount = attachmentCount,
    }
end

function api.GetAllMail()
    local numMail = api.GetNumMail()
    local mailList = {}

    for i = 1, numMail do
        local mailId = CM.SafeCall(GetMailId, i)
        if mailId then
            local mailInfo = api.GetMailInfo(mailId)
            if mailInfo then
                table.insert(mailList, mailInfo)
            end
        end
    end

    return mailList
end

CM.DebugPrint("API", "Mail API module loaded")

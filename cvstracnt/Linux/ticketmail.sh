#! /bin/sh

# 收件人邮件地址
mailto=$1
# %a 该任务单分配给的用户名 
assignto=$2
# %d 描述信息 
desc=$3
# %n 任务单编号 
number=$4
# %p 项目名称 
project=$5
# %r 备注信息 
remark=$6
# %s 任务单的状态 
status=$7
# %t 任务单的标题 
title=$8
# %u 修改该任务单的用户名 
change_user=$9

# 发送人
sender="cvstrac"
# 发信人显示名
sender_name="CVSTrac通知"
# 任务单链接
url="http://www.cnpack.org:8008/$project/tktview?tn="

email_title="[任务单更新] $title"
email_content="$project - 任务单更新通知\n\n任务单 $number: $title\n\n$desc\n\n任务单备注:\n\n$remark\n\n任务单属性:\n\n状态: $status\n分配给: $assignto\n修改人: $change_user\n\n$url$number"

printf "From: \"$sender_name\" <$sender>\nTo: $mailto\nCc:\nSubject: $email_title\n$email_content"|/var/qmail/bin/sendmail -oi -oem "$mailto"

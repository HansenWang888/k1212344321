//
//  WDMB.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/2/26.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "WDMB.h"
@implementation WDMB

+ (NSDictionary *)MBToSubject {
    return @{ @"11" : NSLocalizedString(@"道德与法治/品德与生活/品德与社会", nil),
              @"30" : NSLocalizedString(@"理科综合", nil),
              @"12" : NSLocalizedString(@"道德与法治/思想品德/思想政治", nil),
              @"31" : NSLocalizedString(@"文科综合", nil),
              @"13" : NSLocalizedString(@"语文", nil),
              @"40" : NSLocalizedString(@"外语", nil),
              @"14" : NSLocalizedString(@"数学", nil),
              @"41" : NSLocalizedString(@"英语", nil),
              @"15" : NSLocalizedString(@"科学", nil),
              @"42" : NSLocalizedString(@"日语", nil),
              @"16" : NSLocalizedString(@"物理", nil),
              @"43" : NSLocalizedString(@"俄语", nil),
              @"17" : NSLocalizedString(@"化学", nil),
              @"49" : NSLocalizedString(@"其它外国语言", nil),
              @"18" : NSLocalizedString(@"生物", nil),
              @"60" : NSLocalizedString(@"综合实践活动", nil),
              @"19" : NSLocalizedString(@"历史与社会", nil),
              @"61" : NSLocalizedString(@"信息技术", nil),
              @"62" : NSLocalizedString(@"劳动与技术", nil),
              @"20" : NSLocalizedString(@"地理", nil),
              @"21" : NSLocalizedString(@"历史", nil),
              @"22" : NSLocalizedString(@"体育与健康", nil),
              @"23" : NSLocalizedString(@"艺术", nil),
              @"24" : NSLocalizedString(@"音乐", nil),
              @"25" : NSLocalizedString(@"美术", nil),
              @"26" : NSLocalizedString(@"信息技术", nil),
              @"27" : NSLocalizedString(@"通用技术", nil),
              @"28" : NSLocalizedString(@"安全教育", nil),
              @"29" : NSLocalizedString(@"心理健康", nil),
              @"all": NSLocalizedString(@"全部", nil),
              @"98" : NSLocalizedString(@"地校课程", nil),
              @"other" : NSLocalizedString(@"其他", nil),
              @"99" : NSLocalizedString(@"不限", nil),
              @"70" : NSLocalizedString(@"生活语文", nil),
              @"71" : NSLocalizedString(@"生活数学", nil),
              @"72" : NSLocalizedString(@"唱游与律动", nil),
              @"73" : NSLocalizedString(@"运动与保健", nil),
              @"74" : NSLocalizedString(@"绘画与手工", nil),
              @"75" : NSLocalizedString(@"感觉统合", nil),
              @"76" : NSLocalizedString(@"语言康复", nil),
              @"77" : NSLocalizedString(@"生活适应", nil),
              @"78" : NSLocalizedString(@"劳动技能", nil),
              @"80" : NSLocalizedString(@"幼儿语言", nil),
              @"81" : NSLocalizedString(@"幼儿数学", nil),
              @"82" : NSLocalizedString(@"幼儿英语", nil),
              @"83" : NSLocalizedString(@"幼儿科学", nil),
              @"84" : NSLocalizedString(@"幼儿音乐", nil),
              @"85" : NSLocalizedString(@"幼儿游戏", nil),
              @"86" : NSLocalizedString(@"幼儿手工", nil),
              @"87" : NSLocalizedString(@"幼儿舞蹈", nil),
              @"88" : NSLocalizedString(@"幼儿美术", nil),
              @"89" : NSLocalizedString(@"幼儿常识", nil),
              @"90" : NSLocalizedString(@"幼儿社会", nil),
              @"91" : NSLocalizedString(@"幼儿体育", nil),
              @"92" : NSLocalizedString(@"幼儿健康", nil)
              };
}
+ (NSDictionary *)MBToAdjunctImage {
    return @{
             @"MP3":NSLocalizedString(@"file_audio", nil),
             @"WAV":NSLocalizedString(@"file_audio", nil),
             @"WMA":NSLocalizedString(@"file_audio", nil),
             @"OGG":NSLocalizedString(@"file_audio", nil),
             @"APE":NSLocalizedString(@"file_audio", nil),
             @"ACC":NSLocalizedString(@"file_audio", nil),
             @"AAC":NSLocalizedString(@"file_audio", nil),
             @"AMR":NSLocalizedString(@"file_audio", nil),
             @"SWF":NSLocalizedString(@"file_audio", nil),
             @"CAF":NSLocalizedString(@"file_audio", nil),
             //video
             @"MP4":NSLocalizedString(@"file_video", nil),
             @"AVI":NSLocalizedString(@"file_video", nil),
             @"MOV":NSLocalizedString(@"file_video", nil),
             @"FLV":NSLocalizedString(@"file_video", nil),
             @"3GP":NSLocalizedString(@"file_video", nil),
             @"RMVB":NSLocalizedString(@"file_video", nil),
             @"M4V":NSLocalizedString(@"file_video", nil),
             //file
             @"DOC":@"file_doc",
             @"DOCX":@"file_doc",
             @"PDF":@"file_pdf",
             @"PPT":@"file_ppt",
             @"PPTX":@"file_ppt",
             @"TXT":@"file_txt",
             @"XLS":@"file_xls",
             @"XLSX":@"file_xls",
             @"ZIP":@"file_zip",
             @"RAR":@"file_zip",
             //image
             @"PNG":NSLocalizedString(@"file_image", nil),
             @"JPGE":NSLocalizedString(@"file_image", nil),
             @"JPEG":NSLocalizedString(@"file_image", nil),
             @"GIF":NSLocalizedString(@"file_image", nil),
             @"JPG":NSLocalizedString(@"file_image", nil),
             @"BMP":NSLocalizedString(@"file_image", nil),
             @"GPEG":NSLocalizedString(@"file_image", nil),
             //Other
             NSLocalizedString(@"试题", nil):NSLocalizedString(@"file_exam", nil),
             NSLocalizedString(@"试卷", nil):NSLocalizedString(@"file_shijuan", nil),
             };
}

@end

